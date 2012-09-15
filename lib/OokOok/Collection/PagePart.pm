use OokOok::Declare;

# PODNAME: OokOok::Collection::PagePart

collection OokOok::Collection::PagePart {

  use OokOok::Resource::PagePart;

  method constrain_collection ($q, $deep = 0) {
    if($self -> c -> stash -> {page}) {
      $q = $q -> search({
        'me.page_version_id' => $self -> c -> stash -> {page} -> source_version -> id
      });
    }

    $q;
  }

}
