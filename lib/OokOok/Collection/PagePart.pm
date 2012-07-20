package OokOok::Collection::PagePart;

use OokOok::Collection;
use namespace::autoclean;

use OokOok::Resource::PagePart;

sub constrain_collection {
  my($self, $q, $deep) = @_;

  if($self -> c -> stash -> {page}) {
    $q = $q -> search({
      'me.page_version_id' => $self -> c -> stash -> {page} -> source_version -> id
    });
  }

  $q;
}

1;
