package OokOok::Resource::Theme;
use OokOok::Resource;
use namespace::autoclean;
with 'OokOok::Role::Resource::HasEditions';

has '+source' => (
  isa => 'OokOok::Model::DB::Theme',
);

prop name => (
  required => 1,
  type => 'Str',
  maps_to => 'title',
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

has_many theme_layouts => 'OokOok::Resource::ThemeLayout', (
  is => 'ro',
  source => sub { $_[0] -> source -> theme_layouts },
);

has_many editions => 'OokOok::Resource::ThemeEdition', (
  is => 'ro',
  source => sub { $_[0] -> source -> editions },
);

sub can_PUT {
  my($self) = @_;

  $self -> c -> user &&
  $self -> c -> user -> is_admin;
}

sub layout {
  my($self, $uuid) = @_;

  # we want the layout with the name $name that is valid for the
  # time constraint we have
  my $l = $self -> source -> theme_layouts -> find({ uuid => $uuid });
  if($l) {
    return OokOok::Resource::ThemeLayout -> new(
      c => $self -> c,
      date => $self -> date,
      source => $l
    );
  }
}

1;
