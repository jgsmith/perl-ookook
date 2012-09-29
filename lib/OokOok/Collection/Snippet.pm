use OokOok::Declare;

# PODNAME: OokOok::Collection::Snippet

# ABSTRACT: REST collection of project snippets

collection OokOok::Collection::Snippet {

  method constrain_collection ($q, $deep = 0) {
    if($self -> c -> stash -> {project}) {
      $q = $q -> search({
        'me.project_id' => $self -> c -> stash -> {project} -> source -> id
      });
    }

    $q;
  }

  method can_POST {
    if($self -> c -> stash -> {project}) {
      $self -> c -> stash -> {project} -> can_PUT
    }
    else {
      0;
    }
  }

}
