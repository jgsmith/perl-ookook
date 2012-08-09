package OokOok::Collection::BoardMember;

use OokOok::Collection;
use namespace::autoclean;

sub constrain_collection {
  my($self, $q, $deep) = @_;

  my $constrained = 0;

  if($self -> c -> stash -> {board}) {
    $constrained = 1;
    $q = $q -> search({
      'me.board_id' => $self -> c -> stash -> {board} -> source -> id
    });
  }
  elsif($self -> c -> stash -> {project}) {
    $constrained = 1;
    $q = $q -> search({
      'me.board_id' => $self -> c -> stash -> {project} -> board -> source -> id
    });
  }
  elsif($self -> c -> user) {
    $constrained = 1;
    $q = $q -> search({
      'me.user_id' => $self -> c -> user -> id,
    });
  }

  if($self -> c -> stash -> {board_rank}) {
    $constrained = 1;
    $q = $q -> search({
      'me.rank' => $self -> c -> stash -> {board_rank} -> position,
      'me.board_id' => $self -> c -> stash -> {board_rank} -> board -> source -> id,
    });
  }

  if(!$constrained) {
    $q = $q -> search({
      'me.id' => 0
    });
  }

  $q;
}

# who can create a board member?
sub can_POST {
  my($self) = @_;

  my $board;
  if($self -> c -> stash -> {board}) {
    $board = $self -> c -> stash -> {board};
  }
  elsif($self -> c -> stash -> {project}) {
    $board = $self -> c -> stash -> {project} -> board;
  }

  return 0 unless $board;
  return 1 if $board -> can_PUT;

  my $user = $self -> c -> user;

  my $membership = $board -> source -> board_members -> search({
    user_id => $user -> id
  }) -> first;

  return 0 unless $membership;
  my $rank = $membership -> board_rank;
  return 0 unless $rank;

  return 1 if $rank -> has_permission('board.invite');

  return 0;
}

1;

