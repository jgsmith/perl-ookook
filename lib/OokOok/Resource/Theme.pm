package OokOok::Resource::Theme;
use OokOok::Resource;
use namespace::autoclean;
with 'OokOok::Role::Resource::HasEditions';

use OokOok::Resource::LibraryTheme;
use OokOok::Resource::ThemeAsset;
use OokOok::Collection::ThemeAsset;

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

has_many theme_assets => 'OokOok::Resource::ThemeAsset', (
  is => 'ro',
  source => sub { $_[0] -> source -> theme_assets },
);

has_many theme_variables => 'OokOok::Resource::ThemeVariable', (
  is => 'ro',
  source => sub { $_[0] -> source -> theme_variables },
);

has_many theme_styles => 'OokOok::Resource::ThemeStyle', (
  is => 'ro',
  source => sub { $_[0] -> source -> theme_styles },
);

has_many editions => 'OokOok::Resource::ThemeEdition', (
  is => 'ro',
  source => sub { $_[0] -> source -> editions },
);

sub libraries {
  my($self) = @_;

  map {
    OokOok::Resource::LibraryTheme -> new(
      c => $self -> c,
      source => $_,
      date => $self -> date
    )
  } $self -> source -> library_themes;
}

sub can_PUT {
  my($self) = @_;

  $self -> c -> user &&
  $self -> c -> user -> is_admin;
}

sub can_PLAY {
  my($self) = @_;

  return 0 if !$self -> source_version;

  return 1 if $self -> source_version -> is_closed;

  return 1 if $self -> c -> model('DB') -> schema -> is_development;

  # make sure the logged in user is a member of the board
  return 0 unless $self -> c -> user;

  return 1 if $self -> c -> user -> is_admin;

  return 0 unless $self -> board;

  my $memberq = $self -> board -> source -> board_members -> search({
    user_id => $self -> c -> user -> id
  }) -> count;

  return 1 if $memberq;

  return 0;
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

sub style {
  my($self, $uuid) = @_;

  my $l = $self -> source -> theme_styles -> find({ uuid => $uuid });
  if($l) {
    return OokOok::Resource::ThemeStyle -> new(
      c => $self -> c,
      date => $self -> date,
      source => $l
    );
  }
}

sub snippet {
  my($self, $name) = @_;

  # we want to find the right snippet_version that corresponds to our
  # date/dev constraints
  my $s = $self -> c -> model('DB::ThemeSnippetVersion') -> search({
    'me.name' => $name,
    'edition.theme_id' => $self -> source -> id,
  }, {
     join => [qw/edition/],
     order_by => { -desc => 'me.theme_edition_id' },
  }) -> first;

  if($s) {
    return OokOok::Resource::ThemeSnippet -> new(
      c => $self -> c,
      date => $self -> date,
      source => $s -> snippet,
    );
  }
}


1;
