use OokOok::Declare;

# PODNAME: OokOok::Collection::Page

collection OokOok::Collection::Page {

  method constrain_collection ($q, $deep = 0) {
    if($self -> c -> stash -> {project}) {
      $q = $q -> search({
        'me.project_id' => $self -> c -> stash -> {project} -> source -> id
      });
    }

    $q;
  }

  method can_POST {
    $self -> c -> stash -> {project} &&
    $self -> c -> stash -> {project} -> can_PUT;
  }

}
