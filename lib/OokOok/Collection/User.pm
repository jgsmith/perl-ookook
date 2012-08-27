package OokOok::Collection::User;

use OokOok::Collection;
use namespace::autoclean;

sub constrain_collection {
  my($self, $q, $deep) = @_;

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

1;

