package OokOok::Base::Resource;
use Moose;
use namespace::autoclean;

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

  if(!$self -> has_source) { die "Unable to create resource link" }

  $self -> collection -> link . '/' . $self -> source -> uuid;
}

sub link_for {
  my($self, $for) = @_;

  if($for eq 'root') { return $self -> c -> uri_for('/'); }

  my $class = blessed $self;
  my $meta = $self -> meta;

  if($meta -> has_embedded($for)) {
    return $self -> link . '/' . $for;
  }
  if($meta -> has_owner($for)) {
    return $self -> $for -> link;
  }
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

sub GET {
  my($self, $deep) = @_;

  if(!$self -> has_source) { die "Unable to GET resource without source"; }

  my $json = inner;
  $json = {} unless defined $json;

  if($self -> can("link")) {
    $json -> {_links} //= {};
    $json -> {_links} -> {self}  = $self -> link;
  }

  if($self -> collection) {
    $json -> {_links} //= {};
    $json -> {_links} -> {collection} = $self -> collection -> link;
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
    my $value;
    if($prop->{source}) {
      $value = $prop->{source} -> ($self);
    }
    elsif($prop->{method}) {
      my $method = $prop->{method};
      $value = $self -> source -> $method;
    }
    else {
      $value = $self -> source -> $key;
    }
    $json -> {$key} = $value;
  }

  for my $key ($meta -> get_embedded_list) {
    $json -> {_embedded} //= {};
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

  return $json;
}

sub DELETE { 
  my($self) = @_;

  if(!$self -> has_source) { die "Unable to DELETE without source"; }

  $self -> source -> delete; 
}

1;
