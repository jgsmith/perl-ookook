package OokOok::Resource::ThemeVariable;

use OokOok::Resource;

prop id => (
  is => 'ro',
  source => sub { $_[0] -> source -> uuid }
);

prop unused => (
  is => 'rw',
  isa => 'Bool',
  source => sub { $_[0] -> source_version -> unused },
);

prop name => (
  is => 'rw',
  isa => 'Str',
  source => sub { $_[0] -> source_version -> name },
);

prop description => (
  is => 'rw',
  isa => 'Str',
  source => sub { $_[0] -> source_version -> description },
);

# type should be 'length', 'color', 'typeface', 'width', 'height', 'percent'
prop type => (
  is => 'rw',
  isa => 'Str',
  source => sub { $_[0] -> source_version -> type },
);

prop default_value => (
  is => 'rw',
  isa => 'Str',
  source => sub { $_[0] -> source_version -> default_value },
);

prop status => (
  is => 'rw',
  isa => 'Int',
  source => sub { $_[0] -> source_version -> status },
);

belongs_to theme => 'OokOok::Resource::Theme', (
  is => 'ro',
  source => sub { $_[0] -> source -> theme },
);

sub can_PUT {
  my($self) = @_;

  $self -> theme -> can_PUT;
}

1;
