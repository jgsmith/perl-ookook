use OokOok::Declare;

# PODNAME: OokOok::Collection::ThemeSnippet

collection OokOok::Collection::ThemeSnippet {

  method constrain_collection ($q, $deep = 0) {
    if($self -> c -> stash -> {theme}) {
      $q = $q -> search({
        'me.theme_id' => $self -> c -> stash -> {theme} -> source -> id
      });
    }

    $q;
  }

  method can_POST {
    return 0 unless $self -> c -> stash -> {theme};
    return $self -> c -> stash -> {theme} -> can_PUT;
  }

  method may_POST { 1 }

}
