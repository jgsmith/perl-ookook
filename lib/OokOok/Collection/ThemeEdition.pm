use OokOok::Declare;

# PODNAME: OokOok::Collection::ThemeEdition

collection OokOok::Collection::ThemeEdition {

  has theme => (
    is => 'rw',
    isa => 'OokOok::Resource::Theme',
    lazy => 1,
    default => sub { $_[0] -> c -> stash -> {theme} },
  );

  method can_POST {
    # we need to make sure the current logged in person is owner of the project
    return 0 unless $self -> theme;
    return $self -> theme -> can_PUT;
  }

  method may_POST {
    if($self -> theme -> source -> current_edition -> created_on <
       DateTime->now) {
      return 1;
    }
    return 0;
  }

  method POST (HashRef $json) {
    # we ignore data in a POST to create a new edition
    my $theme = $self -> theme -> source;

    $theme -> current_edition -> close;

    return OokOok::Resource::ThemeEdition -> new(
      c => $self -> c, 
      date => $self -> date, 
      source => $theme -> current_edition,
    );
  }

  method GET ($deep = 0) {
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

}
