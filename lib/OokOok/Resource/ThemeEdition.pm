use OokOok::Declare;

# PODNAME: OokOok::Resource::ThemeEdition

# ABSTRACT: Theme Edition REST Resource

resource OokOok::Resource::ThemeEdition {

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
    source => sub { $_[0] -> source -> created_on -> iso8601 }
  );

  prop closed_on => (
    is => 'ro',
    isa => 'Str',
    source => sub { "".($_[0] -> source -> closed_on || "") }
  );

  method link {
    $self -> collection -> link . '/edition';
  }

  # modification is through the theme
  method can_PUT { 0 }
}
