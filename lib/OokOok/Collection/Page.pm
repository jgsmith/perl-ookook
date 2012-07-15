package OokOok::Collection::Page;

use OokOok::Collection;
use namespace::autoclean;

use OokOok::Resource::Page;

sub constrain_collection {
  my($self, $q, $deep) = @_;

  if($self -> c -> stash -> {project}) {
    $q = $q -> search({
      'me.project_id' => $self -> c -> stash -> {project} -> source -> id
    });
  }

  $q;
}

1;
