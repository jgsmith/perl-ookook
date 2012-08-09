package OokOok::Collection::ThemeEdition;

use OokOok::Collection;
use namespace::autoclean;

has theme => (
  is => 'rw',
  isa => 'OokOok::Resource::Theme',
  lazy => 1,
  default => sub { $_[0] -> c -> stash -> {theme} },
);

sub can_POST {
  my($self) = @_;

  # we need to make sure the current logged in person is owner of the project
  return 0 unless $self -> theme;
  return $self -> theme -> can_PUT;
}

sub may_POST {
  my($self) = @_;

  if($self -> theme -> source -> current_edition -> created_on <
       DateTime->now) {
    return 1;
  }
  return 0;
}

sub POST {
  my($self, $json) = @_;

  # we ignore data in a POST to create a new edition
  my $theme = $self -> theme -> source;

  $theme -> current_edition -> close;

  return OokOok::Resource::ThemeEdition -> new(
    c => $self -> c, 
    date => $self -> date, 
    source => $theme -> current_edition,
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
        OokOok::Resource::ThemeEdition->new(c => $self -> c, source => $_) -> GET
     } $self -> theme -> source -> editions
    ]
  };
}

1;
