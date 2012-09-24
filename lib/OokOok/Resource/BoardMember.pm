use OokOok::Declare;

# PODNAME: OokOok::Resource::BoardMember

# ABSTRACT: Board Member REST Resource

resource OokOok::Resource::BoardMember {

  prop id => (
    is => 'ro',
    source => sub { 
      $_[0] -> source -> board_rank -> uuid 
      . "/" . $_[0] -> source -> user -> uuid 
    },
  );

  belongs_to board_rank => 'OokOok::Resource::BoardRank', (
    is => 'ro',
    required => 1,
  );

  belongs_to user => 'OokOok::Resource::User', (
    is => 'ro',
    required => 1,
  );

  prop rank => (
    is => 'ro',
    source => sub { $_[0] -> source -> board_rank -> position }
  );

  has_many board_members => 'OokOok::Resource::BoardMember', (
    is => 'ro',
    source => sub { $_[0] -> source -> board_members },
  );

  method can_GET { $self -> board -> can_GET }
  method can_PUT { 
    # you can only modify this if you have permission *and*
    # you are a higher rank
    my $user_membership = $self -> c -> user -> board_membership(
      $self -> source -> board
    );

    return 0 unless $user_membership;

    return 0 unless $user_membership -> board_rank -> position <
                     $self -> source -> board_rank -> position ;

    $self -> c -> user -> has_permission( 
      $self -> source -> board,
      'board.member.PUT'
    )
  }

  method filter_PUT (HashRef $json) {
    my $is_admin = $self -> c -> user -> is_admin;
    my $user_membership = $self -> c -> user -> board_membership(
      $self -> source -> board
    );

    my $board_rank;

    if(exists($json -> {board_rank}) && defined($json -> {board_rank})) {
      $board_rank = delete $json->{board_rank};
      $board_rank = $self -> source -> board -> board_ranks -> find({
        uuid => $board_rank
      });
    }
    if(exists($json -> {rank}) && defined($json->{rank})) {
      my $rank = delete $json -> {rank};
      $board_rank = $self -> source -> board -> board_ranks -> find({
        position => $rank
      });
    }
    if($board_rank && $board_rank -> position != $self -> rank) {
      if($is_admin || $user_membership) {
        if($is_admin || $board_rank->position > $user_membership -> board_rank -> position) {
          my $direction = 'promote';
          $direction = 'demote' if $board_rank -> position > $self -> rank;
          if($is_admin || $user_membership -> board_rank -> has_permission( "board.member.$direction" )) {
            $json -> {board_rank} = $board_rank -> uuid;
          }
        }
      }
    }

    $json;
  }
}
