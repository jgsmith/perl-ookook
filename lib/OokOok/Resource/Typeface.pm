use OokOok::Declare;

# PODNAME: OokOok::Resource::Typeface

# ABSTRACT: Typeface REST Resource

resource OokOok::Resource::Typeface
  with OokOok::Role::Resource::HasEditions {

  #has '+source' => (
  #  isa => 'OokOok::Model::DB::Typeface',
  #);

  prop name => (
    required => 1,
    type => 'Str',
    is => 'rw',
    source => sub { $_[0] -> source_version -> name },
  );

  prop id => (
    is => 'ro',
    type => 'Str',
    source => sub { $_[0] -> source -> uuid },
  );

  prop description => (
    is => 'rw',
    type => 'Str',
    source => sub { $_[0] -> source_version -> description },
  );

  has_many typeface_fonts => 'OokOok::Resource::TypefaceFont', (
    is => 'ro',
    source => sub { $_[0] -> source -> typeface_fonts },
  );

  has_many editions => 'OokOok::Resource::TypefaceEdition', (
    is => 'ro',
    source => sub { $_[0] -> source -> editions },
  );

  method is_built_in {
    # if all of the files associated with the version are unpublished,
    # then we're relying on built-in fonts - name is available, but that's it
    # this assumes that a non-zero status indicates published/available
    # mainly because any non-zero, unpublished version isn't attached
    # to published editions

    0 == scalar(grep { $_ -> status } @{$self -> typeface_fonts||[]})
  }

  method can_PUT {
    $self -> c -> user &&
    $self -> c -> user -> may_design;
  }
}
