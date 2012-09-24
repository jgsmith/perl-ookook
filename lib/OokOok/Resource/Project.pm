use OokOok::Declare;

# PODNAME: OokOok::Resource::Project

# ABSTRACT: Project REST Resource

resource OokOok::Resource::Project
  with OokOok::Role::Resource::HasEditions {

  method edition_resource_class { 'OokOok::Resource::Edition' }

  #has '+source' => (
  #  isa => 'OokOok::Model::DB::Project',
  #);

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

  after EXPORT ($bag) {
    $bag -> add_meta(closed_on => $self -> source_version -> closed_on -> iso8601)
      if $self -> source_version -> closed_on;
  }

  method can_PUT {
    # the user has to be in a rank that can modify the project itself
    # if we get here, we have a user
    # we pull out the top rank held by the user
    if($self -> c -> user) {
      return $self -> c -> user -> has_permission(
        $self -> source -> board,
        'project.settings',
      );
    }
    return 0;
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
}
