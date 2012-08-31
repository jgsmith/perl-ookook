package OokOok::Resource::Board;

use OokOok::Resource;
use namespace::autoclean;

use OokOok::Resource::BoardRank;
use OokOok::Resource::BoardMember;

has '+source' => (
  isa => 'OokOok::Model::DB::Board'
);

prop name => (
  required => 1,
  type => 'Str',
  source => sub { $_[0] -> source -> name },
  maps_to => 'title',
);

prop id => (
  is => 'ro',
  type => 'Str',
  maps_to => 'id',
  source => sub { $_[0] -> source -> uuid },
);

has_many 'board_members' => 'OokOok::Resource::BoardMember', (
  is => 'ro',
  source => sub { $_[0] -> source -> board_members },
);

has_many 'board_ranks' => 'OokOok::Resource::BoardRank', (
  is => 'ro',
  source => sub { $_[0] -> source -> board_ranks },
);

sub member {
  my($self, $uuid) = @_;

  my $membership = $self -> source -> board_members -> search( { 
    'user.uuid' => $uuid
  }, {
    join => [qw/user/],
    rows => 1,
  } ) -> first;

  if($membership) {
    return OokOok::Resource::BoardMember -> new(
      c => $self -> c,
      source => $membership,
    );
  }
}

sub can_PUT {
  my($self) = @_;

  # the user has to be in the top rank of the board
  my $br = $self -> source -> board_members -> search({
    'me.rank' => 0,
    'me.user_id' => $self -> c -> user -> id,
  }, {
    rows => 1,
  }) -> first;

  if($br) {
    return 1;
  }
}

sub can_GET {
  my($self) = @_;

  my $br = $self -> source -> board_members -> search({
    'me.user_id' => $self -> c -> user -> id,
  }, {
    rows => 1,
  }) -> first;

  if($br) {
    return 1;
  }
}

1;
