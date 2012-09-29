use OokOok::Declare;

# PODNAME: OokOok::Collection::LibraryEdition

# ABSTRACT: REST collection of library editions

collection OokOok::Collection::LibraryEdition {

  has library => (
    is => 'rw',
    isa => 'OokOok::Resource::Library',
    lazy => 1,
    default => sub { $_[0] -> c -> stash -> {library} },
  );

  method can_POST {
    # we need to make sure the current logged in person is owner of the project
    1;
  }

  method may_POST {
    if($self -> library -> source -> current_edition -> created_on <
         DateTime->now) {
      return 1;
    }
    return 0;
  }

  method POST (HashRef $json) {
    # we ignore data in a POST to create a new edition
    my $library = $self -> library -> source;

    $library -> current_edition -> close;

    return OokOok::Resource::LibraryEdition -> new(
      c => $self -> c, 
      date => $self -> date, 
      source => $library -> current_edition,
    );
  }

  method GET ($deep = 0) {
    return {
      _links => {
        $self -> link
      },
      _embedded => [
        map {
          OokOok::Resource::LibraryEdition->new(c => $self -> c, source => $_) -> GET
       } $self -> library -> source -> editions
      ]
    };
  }

}
