package OokOok::Resource::Edition;
use Moose;
use namespace::autoclean;
use OokOok::Resource;

sub resource_collection_class { 'OokOok::Resource::Project' }

has '+collection' => (
  lazy => 1,
  default => sub {
    my($self) = @_;

    OokOok::Resource::Project->new(
      c => $self -> c, 
      source => $self -> source -> project
    );
  },
);

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

augment GET => sub {
  my($self, $deep) = @_;

  my $json = {};

  if($self -> source -> theme) {
    $json -> {theme} = OokOok::Resource::Theme->new(
      source => $self -> source -> theme,
      c => $self -> c
    ) -> link
    #$json -> {theme_date} = $self -> source -> theme_date;
  }

  return $json;
};

sub link {
  my($self) = @_;

  $self -> collection -> link . '/edition';
}

1;

__END__
