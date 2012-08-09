package OokOok::Collection::BoardRank;

use OokOok::Collection;
use namespace::autoclean;

sub constrain_collection {
  my($self, $q, $deep) = @_;

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

1;
