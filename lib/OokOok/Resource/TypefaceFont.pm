use OokOok::Declare;

# PODNAME: OokOok::Resource::TypefaceFont

resource OokOok::Resource::TypefaceFont {

  prop id => (
    is => 'ro',
    isa => 'Str',
    source => sub { $_[0] -> source -> uuid },
  );

  prop weight => (
    is => 'rw',
    isa => 'Str',
    source => sub { $_[0] -> source_version -> weight },
  );

  prop style => (
    is => 'rw',
    isa => 'Str',
    source => sub { $_[0] -> source_version -> style },
  );

  has_many typeface_font_files => 'OokOok::Resource::TypefaceFontFile', (
    is => 'ro',
    source => sub { $_[0] -> source_version -> typeface_font_files },
  );
}
