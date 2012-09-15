use MooseX::Declare;

# PODNAME: OokOok::Declare::Base::Resource

# ABSTRACT: Base class for resource classes

class OokOok::Declare::Base::Resource {
  use Lingua::EN::Inflect qw(PL_V);
  use String::CamelCase qw(decamelize);
  use OokOok::Exception;
  use OokOok::Bag;
  use OokOok::DateTime::Parser;

  has c => (
    is => 'rw',
    isa => 'Object',
    required => 1,
  );

  has is_development => (
    is => 'rw',
    isa => 'Bool',
    default => sub {
      $_[0] -> c -> stash -> {development}
    },
  );

  has date => (
    is => 'rw',
    lazy => 1,
    default => sub { 
      my $self = shift;
      if(!$self -> is_development) {
        my $date = $self -> c -> stash -> {date};
        if(!$date) {
          $date = DateTime->now;
          $date -> set_formatter('OokOok::DateTime::Parser');
        }
      }
    },
    trigger => sub {
      my($self, $date) = @_;
      if($self -> source && !$self -> is_development) {
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
    default => sub { 
      if($_[0] -> source) {
        $_[0] -> _get_source_version( $_[0] -> source );
      }
    },
  );

  has collection => (
    is => 'rw',
    isa => 'Object',
    lazy => 1,
    default => sub {
      my($self) = @_;
      my $class = $self -> meta -> resource_collection_class;
      eval { Module::Load::load($class) };
      if($@) {
        warn "Unable to load $class as collection for ", (ref($self)||$self), "\n";
      }
      else {
        $class -> new( 
          c => $self -> c, 
          is_development => $self -> is_development, 
          date => $self -> date 
        );
      }
    },
  );

  method resource_name { $self -> meta -> resource_name; }

  method link {
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

  method link_for (Str $for) {
    if($for eq 'root') { return $self -> c -> uri_for('/'); }

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

  method schema { 
    my $schema = $self -> meta -> schema;

    for my $k (keys %{$schema -> {embedded}}) {
      $schema -> {embedded} -> {$k} -> {_links} -> {self} = $self -> link_for($k);
    }
    for my $h ($self -> meta -> get_hasa_list) {
      my $info = $self -> meta -> get_hasa($h);
      $schema -> {properties} -> {$h} -> {linkListFrom} = 
        $info->{isa} -> new(
          c => $self -> c,
          date => $self -> date,
          is_development => $self -> is_development,
        ) -> collection -> link;
    }
    return $schema;
  }

  method can_GET { 
    return 0 unless $self -> source;
    return 1 unless $self -> source -> can('version_for_date');
    return 0 unless $self -> source_version;
    return 1;
  }

  method can_PUT { $self -> is_development; }
  method can_DELETE { $self -> is_development; }

  method _export_resource ($bag, $r) {
    if($r -> source -> can("uuid")) {
      $bag -> with_data_directory( $r -> source -> uuid, sub {
        $r -> EXPORT($bag);
      });
    }
  }

  method _EXPORT {

    my $bag = OokOok::Bag -> new;
    $self -> EXPORT($bag);
    $bag -> write;
  }

  method EXPORT ($bag) {

    if($self -> source -> can('uuid')) {
      $bag -> add_meta(uuid => $self -> source -> uuid);
    }

    my $default_type = ref($self) || $self;
    $default_type =~ s{^.*::}{};
    $default_type = decamelize($default_type);
    $default_type =~ tr{_}{ };
    $bag -> add_meta( type => $default_type );

    for my $key ($self -> meta -> get_prop_list) {
      next if $key eq 'id'; # we use uuid for this
      my $pinfo = $self -> meta -> get_prop($key);
      next if defined($pinfo->{export}) && !$pinfo->{export};
      if($pinfo -> {export_as_file}) {
        $bag -> add_data($pinfo -> {export_as_file}, $self -> $key);
      }
      else {
        $bag -> add_meta($key, $self -> $key);
      }
    }
    for my $key ($self -> meta -> get_hasa_list) {
      my $hinfo = $self -> meta -> get_hasa($key);
      next if defined($hinfo->{export}) && !$hinfo->{export};
      my $h = $self -> $key;
      if($h) {
        $bag -> add_meta($key, $h -> source -> uuid);
        # if we have a meaningful date that can be changed, then it will 
        # be a prop anyway. Otherwise, the date is assumed to be the same
        # as the date for this object
      }
    }

    for my $key ($self -> meta -> get_embedded_list) {
      my $einfo = $self -> meta -> get_embedded($key);
      next if defined($einfo->{export}) && !$einfo->{export};
      next if $key eq 'editions'; # we don't do these here
      $bag -> with_data_directory( $key, sub {
        $self -> _export_resource( $bag, $_ ) for (@{$self -> $key});
      });
    }

  }

  method _GET ($deep = 0) { 
    OokOok::Exception::GET -> forbidden(
      message => 'Unable to GET resource'
    ) unless $self -> can_GET;

    my $guard = $self -> c -> model('DB') -> txn_scope_guard;

    my $r = $self -> GET($deep);
    $guard -> commit;
    return $r;
  }

  method GET ($deep = 0) {
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
          if($deep) {
            my $info = $i -> GET;
            push @{$json -> {_embedded}->{$key}}, $info;
          }
          else {
            push @{$json -> {_embedded}->{$key}}, +{ _links => {
              self => $i -> link
            }};
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
  
  method GET_oai_pmh ($xmlRoot, $metaFormat, $deep = 0) {
  }

  method _DELETE {
    OokOok::Exception::DELETE -> forbidden(
      message => "Unable to DELETE unless authenticated"
    ) unless $self -> c -> user;

    OokOok::Exception::DELETE -> forbidden(
      message =>  "Unable to DELETE"
    ) unless $self -> can_DELETE;

    my $guard = $self -> c -> model('DB') -> txn_scope_guard;
    my $r = $self -> DELETE;
    $guard -> commit;
    return $r;
  }

  method DELETE { 
    OokOok::Exception::DELETE -> gone(
      message => 'Unable to DELETE without source'
    ) unless $self -> has_source;

    $self -> source -> delete; 
  }

  method _PUT ($json) {
    OokOok::Exception::PUT -> forbidden(
      message => 'Unable to PUT unless authenticated'
    ) unless defined $self -> c -> user;

    OokOok::Exception::PUT -> forbidden(
      message => 'Unable to PUT'
    ) unless $self -> can_GET && $self -> can_PUT;

    my $guard = $self -> c -> model('DB') -> txn_scope_guard;

    my $embeddings = delete $json -> {_embedded};

    my $nested = {};
    for my $n ($self -> meta -> get_nested_list) {
      $nested->{$n} = delete $json -> {$n};
    }

    my $hasa = {};

    for my $h ($self -> meta -> get_hasa_list) {
      my $hinfo = $self -> meta -> get_hasa($h);
      next if defined($hinfo->{is}) && $hinfo->{is} eq 'ro';
      my $h_exists = exists $json->{$h};
      my $r = delete $json -> {$h};
      if(defined $r) {
        my $collection = $hinfo -> {isa} -> new(c => $self -> c) -> collection;
        $r = $collection -> resource_for_url($r);
      }
      if(!$r && $hinfo->{required}) {
          $r = $self -> $h;
      }
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
      my $binfo = $self -> meta -> get_owner($b);
      next if !defined($binfo->{is}) || $binfo->{is} eq 'ro';
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
      $json -> {$h} = $hasa->{$h};
    }
  
    my $verifier = $self -> meta -> verifier -> {PUT};
    if($verifier) {
      my $results = $verifier -> verify($json);
      if(!$results -> success) {
        OokOok::Exception::PUT->throw(
          message => "Invalid or missing fields",
          missing => [ $results -> missings ],
          invalid => [ $results -> invalids ],
        );
      }
      my %values = $results -> valid_values;
      delete @values{grep { !exists $json->{$_} } keys %values};
      $json = \%values;
    }
    else {
      $json = {};
    }
  
    $json -> {_embedded} = {};
    $json -> {_nested} = {};
  
    my $r = $self -> PUT($json);
    $guard -> commit;
    return $r;
  }
  
  method PUT ($json) {
    my $embedded = delete $json -> {_embedded};
    my $nested = delete $json -> {_nested};
  
    if($self -> source_version) {
      my $row = $self -> source_version;
      my $result_source = $row -> result_source;
      my $new_info = {};
      for my $col ($result_source -> columns) {
        if(exists $json -> {$col}) {
          my $colinfo = $result_source -> column_info($col);
          if(!defined($json->{$col}) && !$colinfo->{is_nullable}) {
            next;
          }
          if($colinfo -> {data_type} =~ m{date|time}) {
            my $d = $json -> {$col};
            if(!ref($d)) {
              $d = DateTime::Format::ISO8601 -> parse_datetime($d);
              $json->{$col} = $d;
            }
          }
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
  
  method _get_source_version ($thing) { 
    if($self -> is_development) {
      $self -> meta -> _get_source_version($thing);
    }
    else {
      $self -> meta -> _get_source_version($thing, $self -> date);
    }
  }
}
