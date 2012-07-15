package OokOok::Meta::Resource;

use Moose::Role;
#extends 'Moose::Meta::Class';
use namespace::autoclean;

use Data::Verifier;
use Module::Load;

has resource_name => (
  is => 'rw',
  isa => 'Str',
);

has properties => (
  is => 'rw',
  isa => 'HashRef',
  default => sub { +{ } },
  lazy => 1,
);

has owners => (
  is => 'rw',
  isa => 'HashRef',
  default => sub { +{ } },
  lazy => 1,
);

has embedded => (
  is => 'rw',
  isa => 'HashRef',
  default => sub { +{ } },
  lazy => 1,
);

has schema => (
  is => 'rw',
  isa => 'HashRef',
  lazy => 1,
  builder => '_build_schema',
);

has contains => (
  is => 'rw',
  isa => 'HashRef',
  default => sub { +{ } },
  lazy => 1,
);

has nested => (
  is => 'rw',
  isa => 'HashRef',
  default => sub { +{ } },
  lazy => 1,
);

has resource_collection_class => (
  is => 'rw',
  isa => 'Str',
  lazy => 1,
  default => sub {
    my($self) = @_;
    my $class = $self -> {package};
    $class =~ s{::Resource::}{::Collection::};
    $class;
  },
);

has verifier => (
  is => 'ro',
  isa => 'HashRef',
  lazy => 1,
  builder => '_build_verifiers',
);

sub _build_verifiers {
  my($self) = @_;
  my %profiles = (
    POST => { },
    PUT  => { },
  );

  for my $k (keys %{$self -> properties}) {
    my $p = $self -> properties -> {$k};
    # we only use the verifier for items that don't have a verifier key
    next if defined($p->{is}) && $p->{is} eq 'ro';
    next if defined($p->{verifier});
    $profiles{POST}{$k} = { required => 0  };
    $profiles{PUT}{$k} = { required => 0  };

    for my $kk (qw/type filters max_length min_length dependent/) {
      $profiles{POST}{$k}{$kk} = $p->{$kk} if defined $p->{$kk};
      $profiles{PUT}{$k}{$kk} = $p->{$kk} if defined $p->{$kk};
    }
    for my $kk (qw/required/) {
      $profiles{POST}{$k}{$kk} = $p->{$kk} if defined $p->{$kk};
    }
  }
  for my $k (keys %{$self -> properties}) {
    my $p = $self -> properties -> {$k};
    # we only use the verifier for items that don't have a verifier key
    next if defined($p->{is}) && $p->{is} eq 'ro' && !$p->{required};
    next if defined($p->{verifier});
    #$profiles{POST}{$k} = { };

    for my $kk (qw/type filters max_length min_length dependent/) {
      $profiles{POST}{$k}{$kk} = $p->{$kk} if defined $p->{$kk};
    }
    for my $kk (qw/required/) {
      $profiles{POST}{$k}{$kk} = $p->{$kk} if defined $p->{$kk};
    }
  }

  for my $k (keys %{$self -> owners}) {
    my $p = $self -> owners -> {$k};
    next if defined($p->{is}) && $p->{is} eq 'ro';
    $profiles{POST}{$k . "_id"} = { required => 0 };
    $profiles{PUT}{$k . "_id"} = { required => 0 };
    for my $kk (qw/required/) {
      $profiles{POST}{$k."_id"}{$kk} = $p->{$kk} if defined $p->{$kk};
    }
  }
  for my $k (keys %{$self -> owners}) {
    my $p = $self -> owners -> {$k};
    next if defined($p->{is}) && $p->{is} eq 'ro' && !$p->{required};
    #$profiles{POST}{$k . "_id"} = { required => 0 };
    for my $kk (qw/required/) {
      $profiles{POST}{$k."_id"}{$kk} = $p->{$kk} if defined $p->{$kk};
    }
  }
  for my $k (keys %{$self -> contains}) {
    my $p = $self -> contains -> {$k};
    next if defined($p->{is}) && $p->{is} eq 'ro';
    $profiles{POST}{$k . "_id"} = { required => 0 };
    $profiles{PUT}{$k . "_id"} = { required => 0 };
    for my $kk (qw/required/) {
      $profiles{POST}{$k."_id"}{$kk} = $p->{$kk} if defined $p->{$kk};
    }
  }
  for my $k (keys %{$self -> contains}) {
    my $p = $self -> contains -> {$k};
    next if defined($p->{is}) && $p->{is} eq 'ro' && !$p->{required};
    #$profiles{POST}{$k . "_id"} = { required => 0 };
    for my $kk (qw/required/) {
      $profiles{POST}{$k."_id"}{$kk} = $p->{$kk} if defined $p->{$kk};
    }
  }

  return {
    POST => Data::Verifier -> new(profile => $profiles{POST}),
    PUT  => Data::Verifier -> new(profile => $profiles{PUT }),
  };
}

sub add_prop {
  my($self, $key, %config) = @_;

  if(substr($key, 0, 1) eq '+') {
    $key = substr($key, 1);
    if(!$self -> properties->{$key}) {
      # should be an error
    }
    for my $k (keys %config) {
      $self -> properties -> {$key} -> {$k} = $config{$k};
    }
  }
  elsif($self -> properties->{$key}) {
    # should be an error
  }
  else {
    $self -> properties -> {$key} = \%config;
  }
  my $method = $config{source} || sub { $_[0] -> source -> $key };
  $self -> add_method( $key => $method );
}

sub get_prop_list { keys %{$_[0] -> properties} }

sub get_prop { $_[0] -> properties -> {$_[1]} }

sub _get_source_version {
  my($self, $thing, $date) = @_;

  if($thing) {
    if(!$date) {
      if($thing -> can("current_version")) {
        $thing = $thing -> current_version;
      }
      elsif($thing -> can("current_edition")) {
        $thing = $thing -> current_edition;
      }
    }
    elsif($thing -> can("version_for_date")) {
      $thing = $thing -> version_for_date($date);
    }
    elsif($thing -> can("edition_for_date")) {
      $thing = $thing -> edition_for_date($date);
    }
  }
  $thing;
}

sub get_nested_list { keys %{$_[0] -> nested} }

sub add_hasa {
  my($self, $key, %config) = @_;

  my $resource_class = $config{isa};
  my $method = $config{source};
  my $date   = $config{date} || sub { $_[0] -> date };
  $self -> add_method( $key => sub {
    my($self) = @_;
    my $row = $self->$method();
    if($row) {
      return $resource_class -> new( c => $self->c, date => $self->$date, source => $row );
    }
  } );

  $self -> contains -> {$key} = \%config;
}

sub get_hasa_list { keys %{$_[0]->contains} }

sub get_hasa { $_[0] -> contains -> {$_[1]} }

sub add_owner {
  my($self, $key, %config) = @_;

  my $resource_class = $config{isa};
  my $method = $config{source};
  my $date   = $config{date} || sub { $_[0] -> date };
  $self -> add_method( $key => sub {
    my($self) = @_;
    my $row = $self->$method();
    if($row) {
      return $resource_class -> new( 
        c => $self->c, 
        date => $self -> $date,
        source => $row,
      );
    }
  } );

  $self -> owners -> {$key} = \%config;
}

sub get_owner_list { keys %{$_[0]->owners} }

sub has_owner { defined $_[0]->owners->{$_[1]} }

sub get_owner { $_[0]->owners->{$_[1]} }

sub add_embedded {
  my($self, $key, %config) = @_;

  my $resource_class = $config{isa};
  Module::Load::load($resource_class);
  my $method = $config{source};
  my $date   = $config{date} || sub { $_[0] -> date };
  $self -> add_method( $key => sub {
    my($self) = @_;
    my $row;
    [
      grep { defined $_ } map {
        $_ ? $resource_class -> new( 
               c => $self -> c, 
               date => $self -> $date, 
               source => $_ 
             )
           : undef
      } $self->$method()
    ];
  } );

  $self -> embedded -> {$key} = \%config;
}

sub get_embedded_list { keys %{$_[0]->embedded} }

sub has_embedded { defined $_[0]->embedded->{$_[1]} }

sub get_embedded { $_[0]->embedded->{$_[1]} }

sub _build_schema {
  my($self) = @_;

  my $schema = {};

  for my $prop ($self -> get_prop_list) {
    my $info = $self -> get_prop($prop);
    $schema -> {properties} -> {$prop} -> {source} = $info -> {maps_to} || $prop;
    $schema -> {properties} -> {$prop} -> {is} = $info -> {is} || 'rw';
    $schema -> {properties} -> {$prop} -> {valueType} = $info -> {value_type} || 'text';
  }

  for my $key ($self -> get_embedded_list) {
    $schema -> {embedded} -> {$key} = {};
  }

  for my $key ($self -> get_owner_list) {
    my $info = $self -> get_owner($key);
    $schema -> {belongs_to} -> {$key} = {
      source => $info -> {maps_to} || $key,
      is => $info->{is} || 'ro',
    };
    if($info->{value_type}) {
      $schema -> {belongs_to} -> {$key} -> {valueType} = $info->{value_type};
    }
  }

  $schema;
}

1;
