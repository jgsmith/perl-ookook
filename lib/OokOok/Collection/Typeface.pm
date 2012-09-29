use OokOok::Declare;

# PODNAME: OokOok::Collection::Typeface

# ABSTRACT: REST collection of typefaces

collection OokOok::Collection::Typeface {

  method constrain_collection ($q, $deep = 0) {
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

  method can_POST {
    if($self -> c -> user -> is_admin) {
      return 1;
    }
    return 0;
  }

}
