package OokOok::Base::Collection;

use Moose;
use namespace::autoclean;

use String::CamelCase qw(decamelize);
use Lingua::EN::Inflect qw(PL_N);

has c => (
  is => 'rw',
  required => 1,
  isa => 'Object',
);

sub resource_class { $_[0] -> meta -> resource_class }

sub resource_model { $_[0] -> meta -> resource_model }

sub resource_name { $_[0] -> meta -> resource_name }

sub resource_for_url {
  my($self, $url) = @_;

  my $prefix = $self -> link . '/';
  if(substr($url, 0, length($prefix), '') eq $prefix) {
    if($url =~ m{^([-A-Za-z0-9_]{20})(/|$)}) {
      my $thing = $self -> c -> model($self -> resource_model) -> find({uuid => $1});
      if($thing) {
        return $self -> resource_class -> new(
          source => $thing,
          c => $self -> c,
        );
      }
    }
  }
}

sub verify { 
  my $self = shift;
  $self -> resource_class -> new(c => $self -> c) -> verify(@_) 
}

sub link {
  my($self) = @_;

  my $nom = $self -> resource_class;
  $nom =~ s/^.*:://;
  $nom = decamelize($nom);
  "".$self -> c -> uri_for('/' . $nom);
}

=head1 REST METHODS

The following methods are provided for collections.

=head2 GET

=cut

sub GET {
  my($self, $deep) = @_;

  my $things = $self -> resource_name;
  my $rclass = $self -> resource_class;
  my $things_q = $self -> c -> model($self -> resource_model);

  if($self -> can("constrain_collection")) {
    $things_q = $self -> constrain_collection($things_q, $deep);
  }

  my $json = {
    _links => {
      self => $self -> link
    },
    _embedded => {
      $things => [
        map {
          $rclass -> new(c => $self -> c, source => $_) -> GET
        } $things_q -> all
      ],
    },
  };

  return $json;
}

=head2 POST

=cut

sub POST {
  my($self, $json) = @_;

  die "POST method not implemented";
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
