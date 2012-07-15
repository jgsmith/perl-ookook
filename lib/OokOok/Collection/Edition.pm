package OokOok::Collection::Edition;

use OokOok::Collection;
use namespace::autoclean;

has project => (
  is => 'rw',
  isa => 'OokOok::Resource::Project',
  lazy => 1,
  default => sub { $_[0] -> c -> stash -> {project} },
);

sub can_POST {
  my($self) = @_;

  # we need to make sure the current logged in person is owner of the project
  1;
}

sub may_POST {
  my($self) = @_;

  if($self -> project -> source -> current_edition -> created_on <
       DateTime->now) {
    return 1;
  }
  return 0;
}

sub POST {
  my($self, $json) = @_;

  # we ignore data in a POST to create a new edition
  my $project = $self -> project -> source;

  $project -> current_edition -> close;

  return OokOok::Resource::Edition -> new(
    c => $self -> c, 
    date => $self -> date, 
    source => $project -> current_edition,
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
        OokOok::Resource::Edition->new(c => $self -> c, source => $_) -> GET
     } $self -> project -> source -> editions
    ]
  };
}

1;
