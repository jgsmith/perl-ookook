package OokOok::Base::Resource;
use Moose;
use namespace::autoclean;

use Lingua::EN::Inflect qw(PL_V);
use String::CamelCase qw(decamelize);
use OokOok::Exception;

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
  default => sub { $_[0] -> _get_source_version( $_[0] -> source ) },
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
    $nom =~ s{_}{-}g;
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
    $frag =~ s{_}{-}g;
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
  for my $h ($self -> meta -> get_hasa_list) {
    my $info = $self -> meta -> get_hasa($h);
    $schema -> {properties} -> {$h} -> {linkListFrom} = 
      $info->{isa} -> new(c => $self -> c) -> collection -> link;
  }
  return $schema;
}

sub is_development { $_[0] -> c -> model('DB') -> schema -> is_development }

sub can_GET { 
  my($self) = @_;

  return 0 unless $self -> source;
  return 1 unless $self -> source -> can('version_for_date');
  return 0 unless $self -> source_version;
  return 1;
}

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

  for my $key ($meta -> get_hasa_list) {
    my $o = $self -> $key;
    if($o) {
      if($o -> can("link")) {
        $json -> {_links} -> {$key} = $o -> link;
      }
      if($o -> can('id')) {
        $json -> {$key} = $o -> id;
      }
    }
  }

  return $json;
}

sub GET_oai_pmh {
  my($self, $xmlRoot, $metaFormat, $deep) = @_;

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

  print STDERR "$self -> _PUT\n";

  print STDERR "user: ", $self -> c -> user, "\n";

  OokOok::Exception -> forbidden(
    message => 'Unable to PUT unless authenticated'
  ) unless defined $self -> c -> user;

  print STDERR "Got past authentication requirement\n";

  print STDERR "can_GET:", $self -> can_GET, "\n";
  print STDERR "can_PUT:", $self -> can_PUT, "\n";
  print STDERR "got past printing out can_GET and can_PUT\n";

  OokOok::Exception -> forbidden(
    message => 'Unable to PUT'
  ) unless $self -> can_GET && $self -> can_PUT;

  print STDERR "Got past authorization requirement\n";

  my $embeddings = delete $json -> {_embedded};

  my $nested = {};
  for my $n ($self -> meta -> get_nested_list) {
    $nested->{$n} = delete $json -> {$n};
  }

  my $hasa = {};

  for my $h ($self -> meta -> get_hasa_list) {
    print STDERR ">>> $h\n";
    my $hinfo = $self -> meta -> get_hasa($h);
    next if defined($hinfo->{is}) && $hinfo->{is} eq 'ro';
    my $r = delete $json -> {$h};
    if(defined $r) {
      my $collection = $hinfo -> {isa} -> new(c => $self -> c) -> collection;
      $r = $collection -> resource_for_url($r);
    }
    if(!$r && $hinfo->{required}) {
        $r = $self -> $h;
    }
    if($r) {
      print STDERR "$h => $r => ", $r->source->id, "\n";
      if($hinfo->{sink}) {
        print STDERR "Adding $h to hasa\n";
        $hasa->{$h . "_id"} = $hinfo -> {sink} -> ($r);
      }
      else {
        print STDERR "Adding $h to hasa\n";
        $hasa->{$h."_id"} = $r -> source -> id;
      }
    }
  }

  for my $b ($self -> meta -> get_owner_list) {
    my $binfo = $self -> meta -> get_owner($b);
    next if !defined($binfo->{is}) || $binfo->{is} eq 'ro';
    print STDERR "$b required? ", ($binfo->{required}?'y':'n'),"\n";
    if(exists $json->{$b}) {
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
      else {
        $json -> {$b . "_id"} = $self -> $b -> source -> id;
      }
    }
    elsif($binfo->{required}) {
      $json -> {$b . "_id"} = $self -> $b -> source -> id;
    }
  }

  for my $k (keys %{$self -> meta -> properties}) {
    my $p = $self -> meta -> properties -> {$k};
    next if !$p->{required} || defined($p->{is}) && $p->{is} eq 'ro';
    next if defined($p->{verifier});
    if(!defined($json->{$k})) {
      $json->{$k} = $self -> $k;
    }
  }

  for my $h (keys %$hasa) {
    print STDERR "Copying $h to json...\n";
    $json -> {$h} = $hasa->{$h};
  }

  my $verifier = $self -> meta -> verifier -> {PUT};
  print STDERR "Verifier: $verifier\n";
  print STDERR "Data in: ", Data::Dumper -> Dump([ $json ]);
  if($verifier) {
    my $results = $verifier -> verify($json);
    print STDERR "Verifier success: ", $results -> success, "\n";
    if(!$results -> success) {
      print STDERR "Not successful!\n";
      print STDERR Data::Dumper -> Dump([ [ $results -> missings ], [ $results -> invalids ] ]);
      print STDERR "Throwing error\n";
      OokOok::Exception::PUT->throw(
        message => "Invalid or missing fields",
        missing => [ $results -> missings ],
        invalid => [ $results -> invalids ],
      );
    }
    my %values = $results -> valid_values;
    delete @values{grep { !defined $values{$_} } keys %values};
    $json = \%values;
  }
  else {
    $json = {};
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
