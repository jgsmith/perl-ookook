use OokOok::Declare;

# PODNAME: OokOok::Collection::User

collection OokOok::Collection::User {

  method constrain_collection ($q, $deep = 0) {
    if($self -> c -> user) {
      $q = $q -> search({
        'me.id' => $self -> c -> user -> id
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
