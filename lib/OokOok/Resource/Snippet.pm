use OokOok::Declare;

# PODNAME: OokOok::Resource::Snippet

# ABSTRACT: Snippet REST resource

resource OokOok::Resource::Snippet {

  use Moose::Util::TypeConstraints qw(enum);

  #has '+source' => (
  #  isa => 'OokOok::Model::DB::Snippet',
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
    archive_as_file => 'content',
  );

  prop filter => (
    type => 'Str',
    default => 'HTML',
    source => sub { $_[0] -> source_version -> filter },
  );

  prop status => (
    is => 'rw',
    type => 'Int',
    source => sub { $_[0] -> source_version -> status },
  );

  prop id => (
    is => 'ro',
    type => 'Str',
    source => sub { $_[0] -> source -> uuid },
  );

  belongs_to project => "OokOok::Resource::Project", (
    required => 1,
    is => 'ro',
    source => sub { $_[0] -> source -> project },
  );

  after BAG ($bag) {
    $bag -> add_meta(type => 'snippet');
  }

  method can_PUT { $self -> project -> can_PUT; }

  method can_DELETE { $self -> project -> can_PUT; }

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

  method for_search {
    my $context = OokOok::Template::Context -> new(
      c => $self -> c,
    );

    # assume the top-level page for search context
    $context -> set_resource(page => $self -> project -> home_page);
    $context -> set_resource(project => $self -> project);

    return {
      snippet => $self -> render($context)
    };
  }
}
