package OokOok::Resource::Edition;
use Moose;
use namespace::autoclean;
use OokOok::Resource;

# Changes are made via the project - not the edition
prop name => (
  is => 'ro',
  deep => 1,
  isa => 'Str'
);

prop description => (
  is => 'ro',
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

prop theme_date => (
  is => 'ro',
  isa => 'Str',
  source => sub { "".($_[0] -> source -> theme_date || "") },
);

has_a theme => 'OokOok::Resource::Theme', (
  source => sub { $_[0] -> source -> theme },
  date => sub { $_[0] -> source -> theme_date },
  is => 'ro'
);

has_a page => 'OokOok::Resource::Page', (
  source => sub { $_[0] -> source -> page },
  is => 'ro'
);

sub link {
  my($self) = @_;

  $self -> collection -> link . '/edition';
}

sub can_PUT { 0 }

1;

__END__
