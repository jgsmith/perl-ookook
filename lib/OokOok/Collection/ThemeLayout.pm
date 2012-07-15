package OokOok::Collection::ThemeLayout;

use OokOok::Collection;
use namespace::autoclean;

use OokOok::Resource::ThemeLayout;

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
