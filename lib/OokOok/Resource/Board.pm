use OokOok::Declare;

resource OokOok::Resource::Board {

  #has '+source' => (
  #  isa => 'OokOok::Model::DB::Board'
  #);

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

  method member (Str $uuid) {
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

  method can_PUT {
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

  method can_GET {
    my $br = $self -> source -> board_members -> search({
      'me.user_id' => $self -> c -> user -> id,
    }, {
      rows => 1,
    }) -> first;
  
    if($br) {
      return 1;
    }
  }
}
