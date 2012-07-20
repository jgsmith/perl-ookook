package OokOok::Resource::ThemeEdition;
use Moose;
use namespace::autoclean;
use OokOok::Resource;

#sub resource_collection_class { 'OokOok::Resource::Theme' }
#
#has '+collection' => (
#  lazy => 1,
#  default => sub {
#    my($self) = @_;
#
#    OokOok::Resource::Theme->new(
#      c => $self -> c, 
#      source => $self -> source -> theme
#    );
#  },
#);

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

1;

__END__
