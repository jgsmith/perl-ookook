use OokOok::Declare;

# PODNAME: OokOok::Resource::Edition

# ABSTRACT: Project Edition REST Resource

resource OokOok::Resource::Edition {

  # Changes are made via the project - not the edition
  prop name => (
    is => 'ro',
    deep => 1,
    isa => 'Str'
  );

  prop description => (
    is => 'ro',
    deep => 1,
    isa => 'Str',
  );

  prop created_on => (
    is => 'ro',
    isa => 'Str',
    source => sub { "".$_[0] -> source -> created_on }
  );

  prop closed_on => (
    is => 'ro',
    isa => 'Str',
    source => sub { "".($_[0] -> source -> closed_on || "") }
  );

  prop theme_date => (
    is => 'ro',
    isa => 'Str',
    source => sub { "".($_[0] -> source -> theme_date || "") },
  );

  has_a theme => 'OokOok::Resource::Theme', (
    source => sub { $_[0] -> source -> theme },
    date => sub { $_[0] -> source -> theme_date },
    is => 'ro'
  );

  has_a home_page => 'OokOok::Resource::Page', (
    source => sub { $_[0] -> source -> home_page },
    is => 'ro'
  );

  method link {
    $self -> collection -> link . '/edition';
  }

  method can_PUT { 0 }
}

__END__
