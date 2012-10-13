use OokOok::Declare;

# PODNAME: OokOok::Resource::Project

# ABSTRACT: Project REST Resource

resource OokOok::Resource::Project
  with OokOok::Role::Resource::HasEditions {

  use OokOok::Resource::LibraryProject;

  method edition_resource_class { 'OokOok::Resource::Edition' }

  prop name => (
    required => 1,
    type => 'Str',
    source => sub { $_[0] -> source_version -> name },
    maps_to => 'title',
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

  prop is_locked => (
    type => 'Bool',
    source => sub { $_[0] -> source -> is_locked },
    permission => 'project.lock',
  );

  has_many pages => 'OokOok::Resource::Page', (
    is => 'ro',
    source => sub { $_[0] -> source -> pages },
  );

  has_many editions => 'OokOok::Resource::Edition', (
    is => 'ro',
    source => sub { $_[0] -> source -> editions },
  );

  has_many snippets => 'OokOok::Resource::Snippet', (
    is => 'ro',
    source => sub { $_[0] -> source -> snippets },
  );

  prop theme_date => (
    is => 'rw',
    required => 1,
    type => 'Str',
    default => sub { DateTime -> now },
    source => sub { $_[0] -> source_version -> theme_date -> iso8601 },
  );

  has_a theme => 'OokOok::Resource::Theme', (
    source => sub { $_[0] -> source_version -> theme },
    date => sub { $_[0] -> source_version -> theme_date },
    required => 1,
    is => 'rw',
    maps_to => 'theme',
    value_type => "Theme",
  );

  has_a board => 'OokOok::Resource::Board', (
    source => sub { $_[0] -> source -> board },
    is => 'rw',
    maps_to => 'board',
    value_type => 'Board',
  );

  has_a home_page => 'OokOok::Resource::Page', (
    source => sub { $_[0] -> source_version -> home_page },
    is => 'rw',
  );

  method can_PUT {
    # the user has to be in a rank that can modify the project itself
    # if we get here, we have a user
    # we pull out the top rank held by the user
    $self -> has_permission( 'project.settings' );
  }

  method can_GET {
    # for now, all projects are publicly readable if they are published
    return 1 unless $self -> is_development;

    return 0 unless $self -> c -> user;

    return 1 if $self -> c -> user -> board_membership($self -> source -> board);
  }

  method can_PLAY {
    return 0 if !$self -> source_version;

    return 1 if $self -> source_version -> is_closed;

    if($self -> c -> user) {
      return 1 if $self -> c -> user -> is_admin;
      return 1 if $self -> c -> user -> board_membership(
        $self -> source -> board
      );
    }

    return 0;
  }

  method libraries {
    map {
      OokOok::Resource::LibraryProject -> new(
        c => $self -> c,
        source => $_,
        is_development => $self -> is_development,
        date => $self -> date
      )
    } $self -> source -> library_projects;
  }

  method page (Str $uuid) {
    # we want to find the right snippet_version that corresponds to our
    # date/dev constraints
    my $p = $self -> c -> model('DB::Page') -> search({
      'me.uuid' => $uuid,
      'me.project_id' => $self -> source -> id,
    }) -> first;

    if($p) {
      return OokOok::Resource::Page -> new(
        c => $self -> c,
        is_development => $self -> is_development,
        date => $self -> date,
        source => $p -> page,
      );
    }
  }

  method snippet (Str $name) {
    # we want to find the right snippet_version that corresponds to our
    # date/dev constraints
    my $s = $self -> c -> model('DB::SnippetVersion') -> search({
      'me.name' => $name,
      'edition.project_id' => $self -> source -> id,
    }, {
       join => [qw/edition/],
       order_by => { -desc => 'me.edition_id' },
    }) -> first;

    if($s) {
      return OokOok::Resource::Snippet -> new(
        c => $self -> c,
        is_development => $self -> is_development,
        date => $self -> date,
        source => $s -> snippet,
      );
    }
  }

  method asset (Str $name) {
    return; # we don't have assets yet for projects
    my $s = $self -> c -> model('DB::AssetVersion') -> search({
      'me.name' => $name,
      'edition.project_id' => $self -> source -> id,
    }, {
      join => [qw/edition/],
      order_by => { -desc => 'me.edition_id' },
    }) -> first;

    if($s) {
      return OokOok::Resource::Asset -> new(
        c => $self -> c,
        is_development => $self -> is_development,
        date => $self -> date,
        source => $s -> snippet,
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
