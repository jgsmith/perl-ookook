package OokOok::Collection::ThemeStyle;

use OokOok::Collection;
use namespace::autoclean;

use OokOok::Resource::ThemeStyle;

sub constrain_collection {
  my($self, $q, $deep) = @_;

  if($self -> c -> stash -> {theme}) {
    $q = $q -> search({
      'me.theme_id' => $self -> c -> stash -> {theme} -> source -> id
    });
  }

  $q;
}

sub can_POST {
  my($self) = @_;

  return 0 unless $self -> c -> stash -> {theme};
  return $self -> c -> stash -> {theme} -> can_PUT;
}
sub may_POST { 1 }

1;
