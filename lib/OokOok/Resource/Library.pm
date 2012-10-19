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

  method can_PUT { 0 }

  method documentation(Str $prefix) {
    # see if there's a Perl module implementing our uin:uuid:$id namespace
    my $ns = "uin:uuid:" . $self -> id;
    my @libs = grep { $_ -> meta -> taglib_namespace eq $ns } $self -> c -> taglibraries;
    if(!@libs) {
      return "\n## " . $self -> name . "\n\nNo documentation available.\n";
    }
    return "\n## " . $self -> name . "\n\n" . $libs[0] -> meta -> documentation($prefix) . "\n\n";
  }

}
