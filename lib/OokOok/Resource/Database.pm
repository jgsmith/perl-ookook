use OokOok::Declare;

# PODNAME: OokOok::Resource::Database

# ABSTRACT: Database REST resource

resource OokOok::Resource::Database 
  with OokOok::Role::Resource::HasEditions {

  prop name => (
    required => 1,
    type => 'Str',
    source => sub { $_[0] -> source_version -> name },
  );

  prop id => (
    is => 'ro',
    type => 'Str',
    source => sub { $_[0] -> source -> id },
  );

  prop description => (
    type => 'Str',
    source => sub { $_[0] -> source_version -> description },
  );

  after EXPORT ($bag) {
    # now we want all of the data in a compact form
  }
}
