use OokOok::Declare;

# PODNAME: OokOok::Resource::Library

# ABSTRACT: Library REST Resource

resource OokOok::Resource::Library 
  with OokOok::Role::Resource::HasEditions {

  prop name => (
    required => 1,
    type => 'Str',
    source => sub { $_[0] -> source_version -> name },
  );

  prop id => (
    is => 'ro',
    type => 'Str',
    source => sub { $_[0] -> source -> uuid },
  );

  prop description => (
    type => 'Str',
    source => sub { $_[0] -> source_version -> description },
  );

  has_many editions => 'OokOok::Resource::LibraryEdition', (
    source => sub { $_[0] -> source -> editions },
  );

  after EXPORT ($bag) {
  }

  method can_PUT { 0 }
}
