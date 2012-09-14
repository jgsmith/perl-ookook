use OokOok::Declare;

# PODNAME: OokOok::Resource::Theme

# ABSTRACT: Theme REST Resource

resource OokOok::Resource::Theme
  with OokOok::Role::Resource::HasEditions {

  use OokOok::Resource::LibraryTheme;
  use OokOok::Resource::ThemeAsset;
  use OokOok::Collection::ThemeAsset;

  use YAML::Any;

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

  method _bag_resource ($bag, $r) {
    $bag -> with_data_directory( $r -> id, sub {
      $r -> BAG($bag);
    });
  }

  method BAG ($bag) {
    # each resource that is attached to this edition goes into the bag
    $bag -> with_data_directory('layouts' => sub {
      $self -> _bag_resource($bag, $_) for @{$self -> theme_layouts}
    });
    $bag -> with_data_directory('assets' => sub {
      $self -> _bag_resource($bag, $_) for @{$self -> theme_assets}
    });
    $bag -> with_data_directory('styles' => sub {
      $self -> _bag_resource($bag, $_) for @{$self -> theme_styles}
    });
    $bag -> with_data_directory('variables' => sub {
      $self -> _bag_resource($bag, $_) for @{$self -> theme_variables}
    });
    $bag -> add_meta(description => $self -> description);
    $bag -> add_meta(uuid => $self -> id);
    $bag -> add_meta(name => $self -> name);
    $bag -> add_meta(closed_on => $self -> source_version -> closed_on);
    $bag -> add_meta(type => 'theme edition');
  }

  method libraries {
    map {
      OokOok::Resource::LibraryTheme -> new(
        c => $self -> c,
        source => $_,
        is_development => $self -> is_development,
        date => $self -> date
      )
    } $self -> source -> library_themes;
  }

  method can_PUT {
    $self -> c -> user &&
    $self -> c -> user -> is_admin;
  }

  method can_PLAY {
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

  method layout (Str $uuid) {
    # we want the layout with the name $name that is valid for the
    # time constraint we have
    my $l = $self -> source -> theme_layouts -> find({ uuid => $uuid });
    if($l) {
      return OokOok::Resource::ThemeLayout -> new(
        c => $self -> c,
        is_development => $self -> is_development,
        date => $self -> date,
        source => $l
      );
    }
  }

  method style (Str $uuid) {
    my $l = $self -> source -> theme_styles -> find({ uuid => $uuid });
    if($l) {
      return OokOok::Resource::ThemeStyle -> new(
        c => $self -> c,
        is_development => $self -> is_development,
        date => $self -> date,
        source => $l
      );
    }
  }
  
  method snippet (Str $name) {
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
        is_development => $self -> is_development,
        date => $self -> date,
        source => $s -> snippet,
      );
    }
  }

}
