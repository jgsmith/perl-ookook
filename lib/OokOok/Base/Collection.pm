use MooseX::Declare;

# PODNAME: OokOok::Base::Collection

class OokOok::Base::Collection {

  use String::CamelCase qw(decamelize);
  use Lingua::EN::Inflect qw(PL_N);
  use OokOok::Exception;
  use DateTime::Format::ISO8601;

  has c => (
    is => 'rw',
    required => 1,
    isa => 'Object',
  );

  has is_development => (
    is => 'rw',
    isa => 'Bool',
    default => sub {
      !!$_[0] -> c -> stash -> {development};
    },
  );

  has date => (
    is => 'rw',
    lazy => 1,
    default => sub {
      my $self = shift;
      if(!$self -> is_development) {
        $self -> c -> stash -> {date} || DateTime->now;
      }
    },
  );

  method resource_class { $self -> meta -> resource_class; }

  method resource_model { $self -> meta -> resource_model; }

  method resource_name { $self -> meta -> resource_name; }

  method resource (Str $uuid) {
    my $thing = $self -> c -> model($self -> resource_model) -> find({uuid => $uuid});
    if($thing) {
      return $self -> resource_class -> new(
        source => $thing,
        c => $self -> c,
        date => $self -> date,
      );
    }
  }
 
  method resources ($deep = 0) {
    my $date = $self -> date;
    my $c = $self -> c;
    my $rclass = $self -> resource_class;
    my $things_q = $self -> c -> model($self -> resource_model);

    if($self -> can("constrain_collection")) {
      $things_q = $self -> constrain_collection($things_q, $deep);
    }

    grep { $_ -> can_GET }
    map {
      $rclass -> new(c => $c, source => $_, date => $date)
    } $things_q -> all;
  }

  method resource_for_url (Str $url) {
    my $uuid;
    if($url =~ m{^[-A-Za-z0-9_]{20}$}) {
      $uuid = $url;
    }
    else {
      my $url_base = $self -> link . "/";
      if(substr($url, 0, length($url_base), '') eq $url_base) {
        if($url =~ m{^[-A-Za-z0-9_]{20}$}) {
          $uuid = $url;
        }
      }
    }

    if($uuid) {
      $self -> resource($uuid);
    }
  }

  method verify (
      Str $method, 
      HashRef $data
  ) { 
    my $verifier = $self -> resource_class -> meta -> verifier -> {$method};
    if($verifier) {
      my $results = $verifier -> verify($data);
      if(!$results -> success) {
       OokOok::Exception::POST->throw(
          message => "Invalid or missing fields",
          missing => [ $results -> missings ],
          invalid => [ $results -> invalids ],
        );
      }
      return +{ $results -> valid_values };
    }
    return {}; # if no verifier, we let nothing in
  }

  method schema {
    $self -> resource_class -> new(c => $self -> c) -> schema
  }

  method link {
    my $nom = $self -> resource_class;
    $nom =~ s/^.*:://;
    $nom = decamelize($nom);
    $nom =~ s{_}{-}g;
    $self -> c -> uri_for('/' . $nom) -> as_string;
  }

=head1 REST METHODS

The following methods are provided for collections.

=head2 GET

=cut

  method can_GET { 1 }
  method can_POST { $self->is_development }
  method may_POST { 1 } 

  method _GET ($deep = 0) {
    $self -> GET($deep);
  }

  method GET ($deep = 0) {
    # we want to add paging capabilities so we don't send massive numbers of
    # pages when we only need the schema

  my $json = {
    _links => {
      self => $self -> link
    },
    #_schema => $self -> schema,
    _embedded => [ map { $_ -> GET } $self -> resources($deep) ],
  };

  return $json;
}

=head2 POST

=cut

  method _POST (HashRef $json) {

    OokOok::Exception::POST -> forbidden(
      message => "Unable to POST unless authenticated"
    ) unless $self -> c -> user;

    OokOok::Exception::POST -> forbidden(
      message => "Unable to POST"
    )  unless $self -> can_POST;

    OokOok::Exception::POST -> forbidden(
      message => "Unable to POST at the moment"
    )  unless $self -> may_POST;

    my $guard = $self -> c -> model('DB') -> txn_scope_guard;

    my $resource_class = $self -> resource_class;

    # get these out of the way before creating - if we don't have them in
    # our json or in the c->stash, and they are marked as required, then
    # throw an error
    for my $b ($resource_class -> meta -> get_owner_list) {
      my $binfo = $resource_class -> meta -> get_owner($b);
      my $bv = delete $json -> {$b};
      if($bv) {
        $bv = $binfo -> {isa} -> new(c => $self -> c) -> collection -> resource_for_url($b);
        $bv = $bv -> source if $bv;
        $bv = $bv -> id if $bv;

        OokOok::Exception::POST -> bad_request(
          message => "Unable to find proposed $b"
        ) unless !$binfo->{required} || $bv;

        $json -> {$b . "_id"} = $bv;
      }
      elsif( $self -> c -> stash -> {$b} ) {
        $bv = $self -> c -> stash -> {$b} -> source -> id;
        $json -> {$b . "_id"} = $bv;
      }
    }
  
    my $hasa = {};

    for my $h ($resource_class -> meta -> get_hasa_list) {
      delete $json -> {$h . "_id"}; # keep someone from slipping by
      my $hinfo = $resource_class -> meta -> get_hasa($h);
      next if defined($hinfo->{is}) && $hinfo->{is} eq 'ro';
      my $r_exsits = exists($json -> {$h});
      my $r = delete $json -> {$h};
      next unless defined $r;
      my $collection = $hinfo -> {isa} -> new(c => $self -> c) -> collection;
      $r = $collection -> resource_for_url($r);
      if($r) {
        if($hinfo->{sink}) {
          $json->{$h . "_id"} = $hinfo -> {sink} -> ($r);
        }
        else {
          $json->{$h."_id"} = $r -> source -> id;
        }
      }
    }
  
    my $results = $self -> verify('POST', $json);
    delete @$results{grep { !exists $json->{$_} } keys %$results};
  
    my $r = $self -> POST($results);
    $guard -> commit;
    return $r;
  }
  
  method POST (HashRef $json) {
    my $c = $self -> c;
    my $resource_class = $self -> resource_class;
    my $q = $self -> c -> model($self -> resource_model);

    # not to worry about constraints just yet
    # we want to use any columns in $json that are appropriate for
    # the new resource
    my $new_info = {};

    my $result_source = $self -> c -> model($self -> resource_model) -> result_source;
    for my $col ($result_source -> columns) {
      if(exists $json -> {$col}) {
        if($result_source -> column_info($col) -> {data_type} =~ m{date|time}) {  
          my $d = $json -> {$col};
          if(!ref($d)) {
            $d = DateTime::Format::ISO8601 -> parse_datetime($d);
            $json->{$col} = $d;
          }
        }
  
        $new_info -> {$col} = $json -> {$col};
      }
    }
    my $new_resource = $q -> new($new_info);
  
    if($new_resource -> can("current_version")) {
      $new_resource -> insert;
    }
  
    my $resource = $resource_class -> new(
      c => $c,
      date => $self -> date,
      source => $new_resource,
    );
  
    $resource -> PUT($json);
  }
  
=head2 OPTIONS
  
=cut
  
  method OPTIONS {
    return {
      methods => [qw/GET POST OPTIONS/],
    };
  }
}

__END__ 
