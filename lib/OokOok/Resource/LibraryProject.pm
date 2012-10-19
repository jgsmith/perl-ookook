use OokOok::Declare;

# PODNAME: OokOok::Resource::LibraryProject

# ABSTRACT: REST resource associating a library with a project

resource OokOok::Resource::LibraryProject {

  prop id => (
    type => 'Str',
    is => 'ro',
    source => sub { $_[0] -> source -> library -> uuid },
  );

  prop prefix => (
    type => 'Str',
    required => 1,
    source => sub { $_[0] -> source_version -> prefix },
  );

  belongs_to library => 'OokOok::Resource::Library', (
    required => 1,
    is => 'ro',
    source => sub { $_[0] -> source -> library },
    date => sub { $_[0] -> source_version -> library_date },
  );

  belongs_to project => 'OokOok::Resource::Project', (
    required => 1,
    is => 'ro',
    source_version => sub { $_[0] -> source -> project },
  );

  method documentation {
    $self -> library -> documentation($self -> prefix);
  }

  method can_PUT { 0 }
}
