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
  maps_to => 'id',
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

belongs_to theme => 'OokOok::Resource::Theme', (
  source => sub { $_[0] -> source_version -> theme_edition },
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
    if($sv) { $sv -> page }
  },
  is => 'rw',
);

sub can_PUT {
  my($self) = @_;

  return 1 if $self -> is_development;

  # the user has to be in a rank that can modify the project itself
  # if we get here, we have a user
  my $rank = $self -> c -> model('DB::BoardRank') -> search({
    'board.id' => $self -> source -> project -> board -> id,
    'board_members.user_id' => $self -> c -> user -> id,
  }, {
    joins => [qw/board_members board/],
    rows => 1,
  }) -> first;
  return 0 unless $rank;

  return 1 if $rank -> position == 0; # top rank can always do stuff

  return 0;
}

1;
