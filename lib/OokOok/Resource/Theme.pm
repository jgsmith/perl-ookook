use OokOok::Declare;

# PODNAME: OokOok::Resource::Theme

# ABSTRACT: Theme REST Resource

resource OokOok::Resource::Theme
  with OokOok::Role::Resource::HasEditions {

  use OokOok::Resource::LibraryTheme;
  use OokOok::Resource::ThemeAsset;
  use OokOok::Collection::ThemeAsset;

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
    $self -> has_permission( 'theme.settings' );
  }

  method can_PLAY {
    return 0 if !$self -> source_version;

    return 1 if $self -> source_version -> is_closed;

    if($self -> c -> user) {
      return 1 if $self -> c -> user -> is_admin;
      return 1 if $self -> source -> board &&
        $self -> c -> user -> board_membership(
          $self -> source -> board
        );
    }

    return 1 if $self -> c -> model('DB') -> schema -> is_development;

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
        source => $s -> theme_snippet,
      );
    }
  }

  method asset (Str $name) {
    my $a = $self -> source -> theme_assets -> find({ uuid => $name });
    if($a) {
      return OokOok::Resource::ThemeAsset -> new(
        c => $self -> c,
        is_development => $self -> is_development,
        date => $self -> date,
        source => $a
      );
    }
    my $s = $self -> c -> model('DB::ThemeAssetVersion') -> search({
      'me.name' => $name,
      'edition.theme_id' => $self -> source -> id,
    }, {
       join => [qw/edition/],
       order_by => { -desc => 'me.theme_edition_id' },
    }) -> first;

    if($s) {
      return OokOok::Resource::ThemeAsset -> new(
        c => $self -> c,
        is_development => $self -> is_development,
        date => $self -> date,
        source => $s -> theme_asset,
      );
    }
  }

  after EXPORT ($bag) {
    $bag -> add_meta(
      closed_on => $self -> source_version -> closed_on -> iso8601
    ) if $self -> source_version -> closed_on;

    # add meta info about libraries and prefixes
    my %prefixes;
    for my $lib ($self -> libraries) {
      my $lib_ob = $lib -> library;
      $prefixes{$lib -> prefix} = +{
        library => $lib -> id,
        namespace => 'uin:uuid:' . $lib -> id,
        date => $lib_ob -> date,
        name => $lib_ob -> name,
        description => $lib_ob -> description,
      };
    }
    $bag -> add_meta('libraries', \%prefixes);
  }
}
