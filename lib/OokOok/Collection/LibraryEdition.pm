package OokOok::Collection::LibraryEdition;

use OokOok::Collection;
use namespace::autoclean;

has library => (
  is => 'rw',
  isa => 'OokOok::Resource::Library',
  lazy => 1,
  default => sub { $_[0] -> c -> stash -> {library} },
);

sub can_POST {
  my($self) = @_;

  # we need to make sure the current logged in person is owner of the project
  1;
}

sub may_POST {
  my($self) = @_;

  if($self -> library -> source -> current_edition -> created_on <
       DateTime->now) {
    return 1;
  }
  return 0;
}

sub POST {
  my($self, $json) = @_;

  # we ignore data in a POST to create a new edition
  my $library = $self -> library -> source;

  $library -> current_edition -> close;

  return OokOok::Resource::LibraryEdition -> new(
    c => $self -> c, 
    date => $self -> date, 
    source => $library -> current_edition,
  );
}

sub GET {
  my($self, $deep) = @_;

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

1;
