package OokOok::Resource::Library;
use OokOok::Resource;
use namespace::autoclean;
with 'OokOok::Role::Resource::HasEditions';

prop name => (
  required => 1,
  type => 'Str',
  source => sub { $_[0] -> source_version -> name },
);

prop id => (
  is => 'ro',
  type => 'Str',
  source => sub { $_[0] -> source -> uuid },
);

prop description => (
  type => 'Str',
  source => sub { $_[0] -> source_version -> description },
);

has_many editions => 'OokOok::Resource::LibraryEdition', (
  source => sub { $_[0] -> source -> editions },
);

sub can_PUT { 0 }

1;
