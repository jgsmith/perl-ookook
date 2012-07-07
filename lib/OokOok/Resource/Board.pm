package OokOok::Resource::Board;
use OokOok::Resource;
use namespace::autoclean;

prop name => (
  required => 1,
  type => 'Str',
  source => sub { $_[0] -> source -> name },
  maps_to => 'title',
);

prop id => (
  is => 'ro',
  type => 'Str',
  maps_to => 'id',
  source => sub { $_[0] -> source -> uuid },
);

1;
