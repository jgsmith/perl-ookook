use OokOok::Declare;

# PODNAME: OokOok::Resource::TypefaceFontFile

# ABSTRACT: Typeface font file REST resource

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
