use OokOok::Declare;

# PODNAME: OokOok::Resource::ThemeSnippet

# ABSTRACT: Theme Snippet REST resource

resource OokOok::Resource::ThemeSnippet {

  #has '+source' => (
  #  isa => 'OokOok::Model::DB::ThemeSnippet',
  #);

  prop name => (
    required => 1,
    type => 'Str',
    is => 'rw',
    source => sub { $_[0] -> source_version -> name },
  );

  prop content => (
    is => 'rw',
    type => 'Str',
    source => sub { $_[0] -> source_version -> content },
  );

  prop id => (
    is => 'ro',
    type => 'Str',
    source => sub { $_[0] -> source -> uuid },
  );

  belongs_to theme => "OokOok::Resource::Theme", (
    required => 1,
    is => 'ro',
    source => sub { $_[0] -> source -> theme },
  );

  method can_PUT { $self -> theme -> can_PUT; }

  method render (Object $context) {
    # first, we filter the content
    my $content = $self -> content;
    my $filter = $self -> filter;

    my $formatter = eval {
      "OokOok::Formatter::$filter" -> new
    };
    if($formatter && !$@) {
      $content = $formatter -> format($content);
    }

    return $content;
  }
}
