package OokOok::Meta::Resource;

use Moose::Role;
#extends 'Moose::Meta::Class';
use namespace::autoclean;

use Data::Verifier;
use Module::Load;

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
  default => sub {
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
      $profiles{POST}{$k} = { };
      $profiles{PUT}{$k} = { };

      for my $kk (qw/type filters max_length min_length dependent/) {
        $profiles{POST}{$k}{$kk} = $p->{$kk} if defined $p->{$kk};
        $profiles{PUT}{$k}{$kk} = $p->{$kk} if defined $p->{$kk};
      }
      for my $kk (qw/required/) {
        $profiles{POST}{$k}{$kk} = $p->{$kk} if defined $p->{$kk};
      }
    }

    return {
      POST => Data::Verifier -> new(profile => $profiles{POST}),
      PUT  => Data::Verifier -> new(profile => $profiles{PUT }),
     };
  },
);

sub add_prop {
  my($self, $key, %config) = @_;

  #print STDERR "Adding prop $key\n";

  if(substr($key, 0, 1) eq '+') {
    $key = substr($key, 1);
    $self -> properties -> {$key} //= {};
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
}

sub get_prop_list { keys %{$_[0] -> properties} }

sub get_prop {
  my($self, $k) = @_;

  $self -> properties -> {$k};
}

sub add_owner {
  my($self, $key, %config) = @_;

  #print STDERR "Adding owner $key\n";

  my $resource_class = $config{isa};
  my $method = $config{source};
  $self -> add_method( $key => sub {
    my($self) = @_;
    my $row = $self->$method();
    if($row) {
      return $resource_class -> new( c => $self->c, source => $row );
    }
  } );

  $self -> owners -> {$key} = \%config;
}

sub get_owner_list { keys %{$_[0]->owners} }

sub has_owner { defined $_[0]->owners->{$_[1]} }

sub add_embedded {
  my($self, $key, %config) = @_;

  #print STDERR "Adding embedded $key\n";
  my $resource_class = $config{isa};
  Module::Load::load($resource_class);
  my $method = $config{source};
  $self -> add_method( $key => sub {
    my($self) = @_;
    my $row;
    [
      grep { defined $_ } map {
        $_ ? $resource_class -> new( c => $self -> c, source => $_ )
           : undef
      } $self->$method()
    ];
  } );

  $self -> embedded -> {$key} = \%config;
}

sub get_embedded_list { keys %{$_[0]->embedded} }

sub has_embedded { defined $_[0]->embedded->{$_[1]} }

1;
