use OokOok::Declare;

# PODNAME: OokOok::Collection::Board

# ABSTRACT: REST collection of boards

collection OokOok::Collection::Board {

  use OokOok::Collection::BoardRank;
  use OokOok::Collection::BoardMember;

  method constrain_collection ($q, $deep = 0) {
    if($self -> c -> user) {
      $q = $q -> search({
        'board_members.user_id' => $self -> c -> user -> id
      }, {
        join => {board_ranks => 'board_members'}
      });
    }
    else {
      $q = $q -> search({
        'me.id' => 0
      });
    }

    $q;
  }
}
