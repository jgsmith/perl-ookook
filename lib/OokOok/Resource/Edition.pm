package OokOok::Resource::Edition;
use Moose;
use namespace::autoclean;
use OokOok::Resource;

#sub resource_collection_class { 'OokOok::Resource::Project' }
#
#has '+collection' => (
#  lazy => 1,
#  default => sub {
#    my($self) = @_;
#
#    OokOok::Collection::Project->new(
#      c => $self -> c, 
#    ) -> resource($self -> source -> project -> uuid);
#  },
#);

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

1;

__END__
