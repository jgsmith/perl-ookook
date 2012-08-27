package OokOok::Collection::Page;

use OokOok::Collection;
use namespace::autoclean;

use OokOok::Resource::Page;
use OokOok::Collection::PagePart;

sub constrain_collection {
  my($self, $q, $deep) = @_;

  if($self -> c -> stash -> {project}) {
    $q = $q -> search({
      'me.project_id' => $self -> c -> stash -> {project} -> source -> id
    });
  }

  $q;
}

sub can_POST {
  my($self) = @_;

  $self -> c -> stash -> {project} &&
  $self -> c -> stash -> {project} -> can_PUT;
}

1;
