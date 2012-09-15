use OokOok::Declare;

# PODNAME: OokOok::Collection::BoardRank

collection OokOok::Collection::BoardRank {

  method constrain_collection ($q, $deep = 0) {
    if($self -> c -> stash -> {board}) {
      $q = $q -> search({
        'me.board_id' => $self -> c -> stash -> {board} -> source -> id
      });
    }
    elsif($self -> c -> stash -> {project}) {
      $q = $q -> search({
        'me.board_id' => $self -> c -> stash -> {project} -> board -> source -> id
      });
    }
    elsif($self -> c -> user) {
      $q = $q -> search({
        'board_members.user_id' => $self -> c -> user -> id,
      }, {
        join => { 'board' => 'board_members' },
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
