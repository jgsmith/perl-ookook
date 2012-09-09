use OokOok::Declare;

# PODNAME: OokOok::Resource::LibraryTheme

# ABSTRACT: REST resource associating a library with a theme

resource OokOok::Resource::LibraryTheme {

  #has '+source' => (
  #  isa => 'OokOok::Model::DB::LibraryTheme',
  #);

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

  belongs_to theme => 'OokOok::Resource::Theme', (
    required => 1,
    is => 'ro',
    source_version => sub { $_[0] -> source -> theme },
  );

  method can_PUT { 0 }
}
