package OokOok::Resource::ThemeAsset;
use OokOok::Resource;

use namespace::autoclean;

has '+source' => (
  isa => 'OokOok::Model::DB::ThemeAsset',
);

prop id => (
  is => 'ro',
  source => sub { $_[0] -> source -> uuid },
);

prop name => (
  is => 'rw',
  source => sub { $_[0] -> source_version -> name },
  isa => 'Str',
);

prop filename => (
  is => 'ro',
  source => sub { $_[0] -> source_version -> filename },
);

prop type => (
  is => 'ro',
  source => sub { $_[0] -> source_version -> type },
);

prop size => (
  is => 'ro',
  source => sub { $_[0] -> source_version -> size },
);

belongs_to theme => 'OokOok::Resource::Theme', (
  required => 1,
  is => 'ro',
  source => sub { $_[0] -> source -> theme },
);

sub can_PUT { $_[0] -> theme -> can_PUT }

1;
