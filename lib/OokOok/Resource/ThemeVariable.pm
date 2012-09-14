use OokOok::Declare;

# PODNAME: OokOok::Resource::ThemeVariable

# ABSTRACT: Theme Variable REST Resource

resource OokOok::Resource::ThemeVariable {

  prop id => (
    is => 'ro',
    source => sub { $_[0] -> source -> uuid }
  );

  prop unused => (
    is => 'rw',
    isa => 'Bool',
    source => sub { $_[0] -> source_version -> unused },
  );

  prop name => (
    is => 'rw',
    isa => 'Str',
    source => sub { $_[0] -> source_version -> name },
  );

  prop description => (
    is => 'rw',
    isa => 'Str',
    source => sub { $_[0] -> source_version -> description },
  );

  # type should be 'length', 'color', 'typeface', 'width', 'height', 'percent'
  prop type => (
    is => 'rw',
    isa => 'Str',
    source => sub { $_[0] -> source_version -> type },
  );

  prop default_value => (
    is => 'rw',
    isa => 'Str',
    source => sub { $_[0] -> source_version -> default_value },
  );

  prop status => (
    is => 'rw',
    isa => 'Int',
    source => sub { $_[0] -> source_version -> status },
  );

  belongs_to theme => 'OokOok::Resource::Theme', (
    is => 'ro',
    source => sub { $_[0] -> source -> theme },
  );

  method BAG ($bag) {
    $bag -> add_meta(uuid => $self -> id);
    $bag -> add_meta(type => 'theme variable');
    $bag -> add_meta(variable_type => $self -> type);
    $bag -> add_meta(default_value => $self -> default_value);
    $bag -> add_meta(status => $self -> status);
    $bag -> add_meta(description => $self -> description);
    $bag -> add_meta(name => $self -> name);
    $bag -> add_meta(unused => $self -> unused);
  }

  method can_PUT { $self -> theme -> can_PUT; }
}
