use OokOok::Declare;

# PODNAME: OokOok::Resource::ThemeAsset

# ABSTRACT: Theme Asset REST resource

resource OokOok::Resource::ThemeAsset {
  use Image::Info qw(image_info);
  use File::Copy qw(cp);

  prop id => (
    is => 'ro',
    source => sub { $_[0] -> source -> uuid },
  );

  prop name => (
    is => 'rw',
    source => sub { $_[0] -> source_version -> name },
    isa => 'Str',
    required => 1,
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

  after EXPORT ($bag) {
    # TODO: add asset content
  }

  method can_PUT { $self -> theme -> can_PUT }

  # this associates the raw content with the resource object
  method PUT_raw (Catalyst::Request::Upload $upload) {
    $self -> c -> log -> debug("in PUT_raw");
    my $img_info = image_info($upload->fh);
    my $info = {
      size => $upload -> size,
      mime_type => $img_info -> {file_media_type},
      width => $img_info -> {width},
      height => $img_info -> {height},
    };

    my $id;
    if($self -> source_version -> file_id) {
      $id = $self -> c -> model('MongoDB') -> update_file(
        $self -> source_version -> file_id, $upload -> fh, $info
      );
    }
    else {
      $id = $self -> c -> model('MongoDB') -> store_file($upload->fh, $info);
      $info -> {file_id} = $id;
    }
    if(!$info->{file_id}) {
      OokOok::Exception::PUT->thrown( status => 500, message => 'Unable to store asset' );
    }
    $self -> PUT($info);
      
    $self;
  }

  #override PUT (HashRef $json) {
  #  $self -> c -> log -> debug("PUTting theme asset");
  #  super;
  #  $self -> c -> log -> debug("Back from super::PUT");
  #  $self -> PUT_raw($json -> {raw}) if $json -> {raw};
  #  $self;
  #}
}
