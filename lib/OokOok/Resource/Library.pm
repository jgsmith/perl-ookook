package OokOok::Resource::Library;
use OokOok::Resource;
use namespace::autoclean;
with 'OokOok::Role::Resource::HasEditions';

prop name => (
  required => 1,
  type => 'Str',
  source => sub { $_[0] -> source -> name },
);

prop id => (
  is => 'ro',
  type => 'Str',
  source => sub { $_[0] -> source -> library -> uuid },
);

prop description => (
  type => 'Str',
  source => sub { $_[0] -> source -> description },
);

has_many editions => 'OokOok::Resource::LibraryEdition', (
  source => sub { $_[0] -> source -> library -> editions },
);

1;
