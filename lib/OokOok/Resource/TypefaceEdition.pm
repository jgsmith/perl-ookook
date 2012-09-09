use OokOok::Declare;

# PODNAME: OokOok::Resource::TypefaceEdition

# ABSTRACT: REST resource of a typeface edition

resource OokOok::Resource::TypefaceEdition {

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

  method is_built_in { }
}

1;
