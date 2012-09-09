use OokOok::Declare;

# PODNAME: OokOok::Resource::TypefaceFontFile

resource OokOok::Resource::TypefaceFontFile {

  prop id => (
    type => 'Str',
    is => 'ro',
  );

  prop filename => (
    type => 'Str',
    is => 'ro',
  );

  prop format => (
    type => 'Str',
    is => 'rw',
  );

  belongs_to typeface_font => 'OokOok::Resource::TypefaceFont', (
    is => 'ro',
    required => 1,
  );

}
