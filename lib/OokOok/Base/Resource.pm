package OokOok::Base::Resource;
use Moose;
use namespace::autoclean;

use Lingua::EN::Inflect qw(PL_V);
use String::CamelCase qw(decamelize);

has c => (
  is => 'rw',
  isa => 'Object',
  required => 1,
);

has source => (
  is => 'rw',
  isa => 'Object',
  predicate => 'has_source',
);

has collection => (
  is => 'rw',
  isa => 'Object',
  lazy => 1,
  default => sub {
    my($self) = @_;
    my $class = $self -> meta -> resource_collection_class;
Module::Load::load($class);
    $class -> new( c => $self -> c);
  },
);

sub link {
  my($self) = @_;

  if(!$self -> has_source) { 
    my $nom = $self -> meta -> {package};
    $nom =~ s{^.*::}{};
    $nom = decamelize($nom);
    $self -> collection -> link . "/:${nom}_id";
  }
  else {
    $self -> collection -> link . '/' . $self -> source -> uuid;
  }
}

sub link_for {
  my($self, $for) = @_;

  if($for eq 'root') { return $self -> c -> uri_for('/'); }

  my $class = blessed $self;
  my $meta = $self -> meta;

  if($meta -> has_embedded($for)) {
    my $frag = $meta -> get_embedded($for) -> {link_fragment} || PL_V($for);
    return $self -> link . '/' . $frag;
  }
  if($meta -> has_owner($for)) {
    return $self -> $for -> link;
  }
}

sub schema { 
  my $self = shift;

  my $schema = $self -> meta -> schema;

  for my $k (keys %{$schema -> {embedded}}) {
    $schema -> {embedded} -> {$k} -> {_links} -> {self} = $self -> link_for($k);
  }

  return $schema;
}

sub verify { 
  my($self, $json) = @_;

  my $method = $self -> c -> request -> method;

  my $results = $self -> meta -> verifier -> {$method} -> verify($json);

  my $values = +{ $results -> valid_values };

  # handle props that have verifiers
  for my $prop ($self -> meta -> get_prop_list) {
    next unless exists $json->{$prop};
    my $properties = $self -> meta -> get_prop($prop);
    my $v = $properties -> {verifier};
    if($v) {
      my $field = Data::Verifier::Field -> new(
      );

      if($properties -> {required} && (
           $method eq 'PUT' && exists($json->{$prop}) && !defined($json->{$prop})
         ||$method eq 'POST' && !defined($json->{$prop})
        )) {
        # add $prop to list of missing
        $results -> fields -> {$prop} = undef;
      }
      else {
        if(!$v -> ($json->{$prop})) {
          $field -> valid(0);
        }
        else {
          $values -> {$prop} = $json -> {$prop};
        }
        $results -> fields -> {$prop} = $field;
      }
    }
  }

  # TODO: better error
  if(!$results -> success) {
    my $error =
       "Invalid data: " . join(", ", $results -> invalids, $results -> missings)
    ;
      
    die $error;
  }


  for my $f ($results -> valids) {
    delete $values->{$f} unless defined $values->{$f};
  }

  return $values;
}

sub can_GET { 1 } # by default, we can read anything
sub can_PUT { 0 } # by default, we can't modify anything
sub can_DELETE { 0 } # by default, we can't delete anything

sub _GET { 
  my $self = shift;

  die "Unable to GET resource" unless $self -> can_GET;

  $self -> GET(@_) 
}

sub GET {
  my($self, $deep) = @_;

  if(!$self -> has_source) { die "Unable to GET resource without source"; }

  my $json = inner;
  $json = {} unless defined $json;

  if($self -> can("link")) {
    $json -> {_links} -> {self}  = $self -> link;
  }

  if($self -> collection) {
    #$json -> {_links} -> {collection} = $self -> collection -> link;
  }

  my $meta = $self -> meta;

  for my $key ($meta -> get_owner_list) {
    my $bt = $self -> $key;
    if($bt && $bt -> can("link")) {
      $json -> {_links} //= {};
      $json -> {_links} -> {$key} = $bt -> link;
    }
  }

  for my $key ($meta -> get_prop_list) {
    my $prop = $meta -> get_prop($key);
    next if $prop->{deep} && !$deep;
    #my $value;
    #if($prop->{source}) {
    #  $value = $prop->{source} -> ($self);
    #}
    #elsif($prop->{method}) {
    #  my $method = $prop->{method};
    #  $value = $self -> source -> $method;
    #}
    #else {
    #  $value = $self -> source -> $key;
    #}
    $json -> {$key} = $self -> $key; #$value;
  }

  for my $key ($meta -> get_embedded_list) {
    $json -> {_embedded} -> {$key} //= [];
    my $hm = $self -> $key;
    $json -> {_links} -> {$key} = $self -> link_for($key);
    if($hm && @{$hm}) {
      for my $i (@{$hm}) {
        my $info = $i -> GET;
        if($deep) {
          push @{$json -> {_embedded}->{$key}}, $info;
        }
        else {
          push @{$json -> {_embedded}->{$key}}, +{ _links => $info->{_links}};
        }
      }
    }
  }

  for my $key ($meta -> get_owner_list) {
    my $o = $self -> $key;
    if($o) {
      $json -> {_links} -> {$key} = $o -> link;
    }
  }

  return $json;
}

sub _DELETE {
  my($self) = @_;

  die "Unable to DELETE unless authenticated" unless $self -> c -> user;

  die "Unable to DELETE" unless $self -> can_DELETE;

  $self -> DELETE
}

sub DELETE { 
  my($self) = @_;

  if(!$self -> has_source) { die "Unable to DELETE without source"; }

  $self -> source -> delete; 
}

sub _PUT {
  my $self = shift;

  die "Unable to PUT unless authenticated" unless $self -> c -> user;

  die "Unable to PUT" unless $self -> can_PUT;

  $self -> PUT(@_);
}

1;
