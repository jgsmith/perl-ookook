use OokOok::Declare;

# PODNAME: OokOok::Resource::ThemeStyle

# ABSTRACT: Theme Style REST Resource

resource OokOok::Resource::ThemeStyle {

  #has '+source' => (
  #  isa => 'OokOok::Model::DB::ThemeStyle',
  #);

  belongs_to 'theme' => 'OokOok::Resource::Theme', (
    is => 'ro',
    required => 1,
    source => sub { $_[0] -> source -> theme },
  );

  #has_many 'theme_layouts' => 'OokOok::Resource::ThemeLayout', (
  #  is => 'ro',
  #  source_version => sub { $_[0] -> source -> theme_layout_versions },
  #);

  prop id => (
    is => 'ro',
    type => 'Str',
    source => sub { $_[0] -> source -> uuid },
  );

  prop name => (
    is => 'rw',
    type => 'Str',
    required => 1,
    source => sub { $_[0] -> source_version -> name },
  );

  prop styles => (
    is => 'rw',
    isa => 'Str',
    required => 1,
    source => sub { $_[0] -> source_version -> styles },
    export_as_file => 'content'
  );

  method can_PUT { $self -> theme -> can_PUT; }

  method render (Object $context?) {
    $self -> styles;
  }
}
