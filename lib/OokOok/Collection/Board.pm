package OokOok::Collection::Board;

use OokOok::Collection;
use namespace::autoclean;

sub constrain_collection {
  my($self, $q, $deep) = @_;

  if($self -> c -> user) {
    $q = $q -> search({
      'board_members.user_id' => $self -> c -> user -> id
    }, {
      join => { board_ranks => 'board_members' }
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
