package OokOok::Resource::Snippet;
use OokOok::Resource;

use namespace::autoclean;

use Moose::Util::TypeConstraints qw(enum);

has '+source' => (
  isa => 'OokOok::Model::DB::Snippet',
);

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

prop filter => (
  type => enum([qw/HTML Markdown BBCode Textile/]),
  values => [qw/HTML Markdown BBCode Textile/],
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

sub can_PUT {
  my($self) = @_;

  $self -> project -> can_PUT;
}

sub can_DELETE {
  my($self) = @_;

  $self -> project -> can_PUT;
}

sub render {
  my($self, $context) = @_;

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

  my $name = $self -> name;
  $name =~ s{[^-A-Za-z0-9_]+}{-}g;
  $name =~ s{-+}{-}g;
  return "<div class='snippet snippet-$name'>" .
           $content .
         "</div>";
}

sub for_search {
  my($self) = @_;

  my $context = OokOok::Template::Context -> new(
    c => $self -> c,
  );

  # assume the top-level page for search context
  $context -> set_resource(page => $self -> project -> page);
  $context -> set_resource(project => $self -> project);

  return {
    snippet => $self -> render($context)
  };
}

1;
