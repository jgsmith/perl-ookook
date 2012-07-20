package OokOok::Resource::Project;
use OokOok::Resource;
use namespace::autoclean;
with 'OokOok::Role::Resource::HasEditions';

has '+edition_resource_class' => (
  default => 'OokOok::Resource::Edition',
);

has '+source' => (
  isa => 'OokOok::Model::DB::Project',
);

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

prop theme_date => (
  is => 'rw',
  required => 1,
  type => 'Str',
  default => sub { DateTime -> now },
  source => sub { "".($_[0] -> source_version -> theme_date || "") },
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

has_a page => 'OokOok::Resource::Page', (
  source => sub { 
    my $sv = $_[0] -> source_version;
    if($sv) { return $sv -> page; }
    return 0;
  },
  is => 'rw',
);

sub can_PUT {
  my($self) = @_;

  return 1 if $self -> is_development;

  # the user has to be in a rank that can modify the project itself
  # if we get here, we have a user
  # we pull out the top rank held by the user
  my $rank = $self -> c -> model('DB::BoardRank') -> search({
    'me.board_id' => $self -> source -> board -> id,
    'board_members.user_id' => $self -> c -> user -> id,
  }, {
    join => [qw/board_members/],
    order_by => 'me.position',
    rows => 1,
  }) -> first;
  return 0 unless $rank;

  return 1 if $rank -> position == 0; # top rank can always do stuff

  return 0;
}

sub snippet {
  my($self, $name) = @_;

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
      date => $self -> date,
      source => $s -> snippet,
    );
  }
}

1;
