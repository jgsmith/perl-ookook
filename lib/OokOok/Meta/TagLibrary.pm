package OokOok::Meta::TagLibrary;

use Moose::Role;
use namespace::autoclean;

has namespace => (
  is => 'rw',
  isa => 'Str',
);

has elements => (
  is => 'rw',
  isa => 'HashRef',
  default => sub { +{} },
);

sub add_element {
  my($self, $tag, %config) = @_;

  $self -> elements -> {$tag} = \%config;
}

sub element { $_[0] -> elements -> {$_[1]} }

1;
