package OokOok::Base::Collection;

use Moose;
use namespace::autoclean;

use String::CamelCase qw(decamelize);
use Lingua::EN::Inflect qw(PL_N);
use OokOok::Exception;

has c => (
  is => 'rw',
  required => 1,
  isa => 'Object',
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
);

sub resource_class { $_[0] -> meta -> resource_class }

sub resource_model { $_[0] -> meta -> resource_model }

sub resource_name { $_[0] -> meta -> resource_name }

sub resource {
  my($self, $uuid) = @_;

  my $thing = $self -> c -> model($self -> resource_model) -> find({uuid => $uuid});
  if($thing) {
    return $self -> resource_class -> new(
      source => $thing,
      c => $self -> c,
      date => $self -> date,
    );
  }
}
 
sub resources {
  my($self, $deep) = @_;

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

sub resource_for_url {
  my($self, $url) = @_;

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

sub verify { 
  my $self = shift;
  my $method = shift;
  my $verifier = $self -> resource_class -> meta -> verifier -> {$method};
  if($verifier) {
    my $results = $verifier -> verify(@_);
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

sub schema {
  my $self = shift;
  $self -> resource_class -> new(c => $self -> c) -> schema
}

sub link {
  my($self) = @_;

  my $nom = $self -> resource_class;
  $nom =~ s/^.*:://;
  $nom = decamelize($nom);
  $nom =~ s{_}{-}g;
  "".$self -> c -> uri_for('/' . $nom);
}

=head1 REST METHODS

The following methods are provided for collections.

=head2 GET

=cut

sub is_development { $_[0] -> c -> model('DB') -> schema -> is_development }

sub can_GET { 1 } # by default, the collection can be retrieved - the list of
                  # items is defined by the constraint on the collection
sub can_POST { $_[0]->is_development } # by default, no one can POST
sub may_POST { 1 } # but if they can, they always can

sub _GET {
  shift -> GET(@_);
}

sub GET {
  my($self, $deep) = @_;

  # we want to add paging capabilities so we don't send massive numbers of
  # pages when we only need the schema

  my $json = {
    _links => {
      self => $self -> link
    },
    _schema => $self -> schema,
    _embedded => [ map { $_ -> GET } $self -> resources($deep) ],
  };

  return $json;
}

=head2 POST

=cut

sub _POST {
  my $self = shift;
  my $json = shift;

  die "Unable to POST unless authenticated" unless $self -> c -> user;

  die "Unable to POST" unless $self -> can_POST;

  die "Unable to POST at the moment" unless $self -> may_POST;

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
      if(!$bv && $binfo->{required}) {
        die "Unable to find proposed $b";
      }
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

  my $results = $self -> verify(POST => $json);

  $self -> POST($results, @_);
}

sub POST {
  my($self, $json) = @_;

  my $c = $self -> c;
  my $resource_class = $self -> resource_class;
  my $q = $self -> c -> model($self -> resource_model);

  # not to worry about constraints just yet
  # we want to use any columns in $json that are appropriate for
  # the new resource
  my $new_info = {};

  for my $col ($self -> c -> model($self -> resource_model) -> result_source -> columns) {
    if(defined $json -> {$col}) {
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

sub OPTIONS {
  my($self) = @_;

  return {
    methods => [qw/GET POST OPTIONS/],
  };
}

1;

__END__ 
