use OokOok::Declare;

# PODNAME: OokOok::Resource::ThemeAsset

# ABSTRACT: Theme Asset REST resource

resource OokOok::Resource::ThemeAsset {
  #has '+source' => (
  #  isa => 'OokOok::Model::DB::ThemeAsset',
  #);

  prop id => (
    is => 'ro',
    source => sub { $_[0] -> source -> uuid },
  );

  prop name => (
    is => 'rw',
    source => sub { $_[0] -> source_version -> name },
    isa => 'Str',
  );

  prop filename => (
    is => 'ro',
    source => sub { $_[0] -> source_version -> filename },
  );

  prop type => (
    is => 'ro',
    source => sub { $_[0] -> source_version -> type },
  );

  prop size => (
    is => 'ro',
    source => sub { $_[0] -> source_version -> size },
  );

  belongs_to theme => 'OokOok::Resource::Theme', (
    required => 1,
    is => 'ro',
    source => sub { $_[0] -> source -> theme },
  );

  method BAG ($bag) {
    $bag -> add_meta( uuid => $self -> id );
    $bag -> add_meta( type => 'theme asset' );
    $bag -> add_meta( size => $self -> size );
    $bag -> add_meta( file_type => $self -> type );
    $bag -> add_meta( name => $self -> name );
    $bag -> add_meta( filename => $self -> filename );
    # TODO: add asset content
  }

  method can_PUT { $self -> theme -> can_PUT }
}
