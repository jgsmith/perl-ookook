package OokOok::Resource::Library;
use OokOok::Resource;
use namespace::autoclean;
with 'OokOok::Base::EditionedResource';

prop name => (
  required => 1,
  type => 'Str',
  source => sub { $_[0] -> source -> current_edition -> name },
);

prop uuid => (
  is => 'ro',
  type => 'Str',
);

prop description => (
  type => 'Str',
  source => sub { $_[0] -> source -> current_edition -> description },
);

has_many editions => 'OokOok::Resource::LibraryEdition';

1;
