use CatalystX::Declare;

# PODNAME: OokOok::Declare::Meta::TagLibrary

# ABSTRACT: Tracks meta-information about tag library classes

role OokOok::Declare::Meta::TagLibrary {
  has namespace => (
    is => 'rw',
    isa => 'Str',
  );

  has elements => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { +{} },
  );

  method add_element (Str $tag, %config) {
    $self -> elements -> {$tag} = \%config;
  }

  method element (Str $tag) {
    $self -> elements -> {$tag}
  }
}
