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

has date => (
  is => 'rw',
  lazy => 1,
  default => sub { 
    my $self = shift;
    if(!$self -> c -> stash -> {development}) {
      $self -> c -> stash -> {date} || DateTime->now;
    }
  },
  trigger => sub {
    my($self, $date) = @_;
    if($self -> source) {
      $self -> source_version( 
        $self -> meta -> _get_source_version($self -> source, $date) 
      );
    }
  },
);

has source => (
  is => 'rw',
  isa => 'Object',
  predicate => 'has_source',
  trigger => sub {
    $_[0] -> source_version( $_[0] -> _get_source_version($_[1]) )
  },
);

has source_version => (
  is => 'rw',
  isa => 'Maybe[Object]',
  predicate => 'has_source_version',
);

has collection => (
  is => 'rw',
  isa => 'Object',
  lazy => 1,
  default => sub {
    my($self) = @_;
    my $class = $self -> meta -> resource_collection_class;
    #Module::Load::load($class);
    $class -> new( c => $self -> c, date => $self -> date );
  },
);

sub resource_name { $_[0] -> meta -> resource_name }

sub link {
  my($self) = @_;

  if(!$self -> has_source) { 
    my $nom = $self -> meta -> {package};
    $nom =~ s{^.*::}{};
    $nom = decamelize($nom);
    $self -> collection -> link . "/{?${nom}_id}";
  }
  else {
    $self -> collection -> link . '/' . $self -> id;
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

sub is_development { $_[0] -> c -> model('DB') -> schema -> is_development }

sub can_GET { 1 } # by default, we can read anything
sub can_PUT { $_[0] -> is_development }
sub can_DELETE { $_[0] -> is_development }

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
      $json -> {_links} -> {$key} = $bt -> link;
    }
  }

  for my $key ($meta -> get_prop_list) {
    my $prop = $meta -> get_prop($key);
    next if $prop->{deep} && !$deep;
    $json -> {$key} = $self -> $key;
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
  my($self, $json) = @_;

  die "Unable to PUT unless authenticated" unless $self -> c -> user;

  die "Unable to PUT" unless $self -> can_PUT;

  my $embeddings = delete $json -> {_embedded};

  my $nested = {};
  for my $n ($self -> meta -> get_nested_list) {
    $nested->{$n} = delete $json -> {$n};
  }

  my $hasa = {};

  for my $h ($self -> meta -> get_hasa_list) {
    my $hinfo = $self -> meta -> get_hasa($h);
    next if defined($hinfo->{is}) && $hinfo->{is} eq 'ro';
    my $r = delete $json -> {$h};
    next unless defined $r;
    my $collection = $hinfo -> {isa} -> new(c => $self -> c) -> collection;
    $r = $collection -> resource_for_url($r);
    if($r) {
      if($hinfo->{sink}) {
        $hasa->{$h . "_id"} = $hinfo -> {sink} -> ($r);
      }
      else {
        $hasa->{$h."_id"} = $r -> source -> id;
      }
    }
  }

  for my $b ($self -> meta -> get_owner_list) {
    if(exists $json->{$b}) {
      my $binfo = $self -> meta -> get_owner($b);
      my $bv = delete $json -> {$b};
      if(defined($bv) && $bv ne '') {
        $bv = $binfo -> {isa} -> new(c => $self -> c) -> collection -> resource_for_url($bv);
        $bv = $bv -> source if $bv;
        if($bv) {
          $json -> {$b . "_id"} = $bv -> id;
        }
      }
      elsif(!$binfo -> {required}) {
        $json -> {$b . "_id"} = undef;
      }
    }
  }

  my $verifier = $self -> meta -> verifier -> {PUT};
  if($verifier) {
    my $results = $verifier -> verify($json);
    if(!$results -> success) {
      die "Invalid data";
    }
    my %values = $results -> valid_values;
    delete @values{grep { !defined $values{$_} } keys %values};
    $json = \%values;
  }
  else {
    $json = {};
  }

  for my $h (keys %$hasa) {
    $json -> {$h} = $hasa->{$h};
  }

  $json -> {_embedded} = {};
  $json -> {_nested} = {};

  $self -> PUT($json);
}

sub PUT {
  my($self, $json) = @_;

  my $embedded = delete $json -> {_embedded};
  my $nested = delete $json -> {_nested};

  if($self -> source_version) {
    my $row = $self -> source_version;
    my $new_info = {};
    for my $col ($row -> result_source -> columns) {
      if($json -> {$col}) {
        $new_info -> {$col} = $json -> {$col};
      }
    }

    $self -> source_version -> set_inflated_columns($new_info);

    $self -> source_version -> update_or_insert;
  }
  else {
    die "Unable to PUT: no data source";
  }

  $self;
}

sub _get_source_version { 
  my $self = shift;
  $self -> meta -> _get_source_version(@_, $self -> date);
}

1;
