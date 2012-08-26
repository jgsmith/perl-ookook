package OokOok::Collection::ThemeVariable;

use OokOok::Collection;
use namespace::autoclean;

use OokOok::Resource::ThemeVariable;

sub constrain_collection {
  my($self, $q, $deep) = @_;

  if($self -> c -> stash -> {theme}) {
    $q = $q -> search({
      'me.theme_id' => $self -> c -> stash -> {theme} -> source -> id
    });
  }

  $q;
}

1;
