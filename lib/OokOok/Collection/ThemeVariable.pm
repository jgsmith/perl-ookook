use OokOok::Declare;

# PODNAME: OokOok::Collection::ThemeVariable

# ABSTRACT: REST collection of theme variables

collection OokOok::Collection::ThemeVariable {

  method constrain_collection ($q, $deep = 0) {
    if($self -> c -> stash -> {theme}) {
      $q = $q -> search({
        'me.theme_id' => $self -> c -> stash -> {theme} -> source -> id
      });
    }

    $q;
  }

}
