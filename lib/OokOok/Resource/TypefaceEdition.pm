package OokOok::Resource::TypefaceEdition;

use OokOok::Resource;
use namespace::autoclean;

prop name => (
  is => 'rw',
  deep => 1,
  isa => 'Str'
);

prop description => (
  is => 'rw',
  deep => 1,
  isa => 'Str',
);

prop created_on => (
  is => 'ro',
  isa => 'Str',
  source => sub { "".$_[0] -> source -> created_on }
);

prop closed_on => (
  is => 'ro',
  isa => 'Str',
  source => sub { "".($_[0] -> source -> closed_on || "") }
);

sub link {
  my($self) = @_;

  $self -> collection -> link . '/edition';
}

sub is_built_in {
}

1;
