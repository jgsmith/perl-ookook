package OokOok::Collection::Typeface;

use OokOok::Collection;
use namespace::autoclean;

sub constrain_collection {
  my($self, $q, $deep) = @_;

  if($self -> c -> user) {
    if($deep) {
      # we want all publicly accessible projects and projects managed by
      # this person
      #$q = $q -> search({
      #  'board_members.user_id' => $self -> c -> user -> id,
      #}, {
      #  join => { board => { board_ranks => 'board_members' } }
      #});
    }
    else {
      # we only want projects managed/owned/edited by this person
      #$q = $q -> search({
      #  'board_members.user_id' => $self -> c -> user -> id,
      #}, {
      #  join => { board => { board_ranks => 'board_members' } }
      #});
    }
  }
  else {
    # we only want projects with a publicly available edition
    $q = $q -> search({
        "editions.closed_on" => { '!=' => undef },
      }, {
        join => [qw/editions/],
      }
    );
  }

  $q;
}

sub can_POST {
  my($self) = @_;

  if($self -> c -> user -> is_admin) {
    return 1;
  }
  return 0;
}

1;

__END__

