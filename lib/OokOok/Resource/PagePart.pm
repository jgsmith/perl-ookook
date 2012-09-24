use OokOok::Declare;

# PODNAME: OokOok::Resource::PagePart

# ABSTRACT: Page Part REST resource

resource OokOok::Resource::PagePart {

  use Moose::Util::TypeConstraints qw(enum);

  prop id => (
    type => 'Str',
    is => 'ro',
    source => sub { $_[0] -> source -> name },
  );

  prop name => (
    required => 1,
    max_length => 64,
    type => 'Str',
    maps_to => 'title',
    source => sub { $_[0] -> source -> name },
  );

  prop content => (
    required => 0,
    type => 'Str',
    deep => 1,
    export_as_file => 'content',
  );

  prop filter => (
    #type => enum([map { s{^.*::}{}; $_ } OokOok->formatters]),
    #values => [map { s{^.*::}{}; $_ } OokOok->formatters],
    type => 'Str',
    default => 'HTML',
  );

  belongs_to "page" => "OokOok::Resource::Page", (
    is => 'ro',
    required => 1,
  );

  method render (Object $context) {
    # first, we filter the content
    my $content = $self -> content;
    my $filter = $self -> filter;

    my $formatter = eval {
      "OokOok::Formatter::$filter" -> new
    };
    if($@) {
      $self -> c -> log -> warn("Unable to create formatter: $@");
    }
    if($formatter && !$@) {
      $content = $formatter -> format($content);
    }
    return $content;
  }

  method link {
    $self -> page -> link . "/page-part/" . $self -> id;
  }

  method can_PUT    { $self -> page -> can_PUT    }
  method can_GET    { $self -> page -> can_GET    }
  method can_DELETE { $self -> page -> can_DELETE }
}

__END__
