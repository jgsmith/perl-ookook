use OokOok::Declare;

# PODNAME: OokOok::Resource::LibraryEdition

# ABSTRACT: library edition REST resource

resource OokOok::Resource::LibraryEdition {

  prop name => (
    is => 'rw',
    deep => 1,
    isa => 'Str'
  );

  prop description => (
    is => 'rw',
    deep => 1,
    isa => 'Str',
  );

  prop created_on => (
    is => 'ro',
    isa => 'Str',
    source => sub { "".$_[0] -> source -> created_on }
  );

  prop closed_on => (
    is => 'ro',
    isa => 'Str',
    source => sub { "".($_[0] -> source -> closed_on || "") }
  );

  method link {
    $self -> collection -> link . '/edition';
  }

  # changes go through the library
  method can_PUT { 0 }

}

__END__
