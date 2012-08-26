package OokOok::Resource::PagePart;
use OokOok::Resource;

use OokOok::Formatter::HTML;
use OokOok::Formatter::Markdown;
use OokOok::Formatter::BBCode;

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
);

prop filter => (
  type => enum([qw/HTML Markdown BBCode/]), #'Str',
  values => [qw/HTML Markdown BBCode/],
  default => 'HTML',
);

belongs_to "page" => "OokOok::Resource::Page", (
  is => 'ro',
  required => 1,
);

sub render {
  my($self, $context) = @_;

  #my $proc = OokOok::Template::Processor -> new(
  #  c => $self -> c,
  #);

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

  # handle taglib registration based on page type and such
  #my $doc = $proc -> parse($content);

  my $name = $self -> source -> name;
  $name =~ s{[^-A-Za-z0-9_]+}{-}g;
  $name =~ s{-+}{-}g;
  return "<div class='page-part page-part-$name'>" .
         #$doc -> render($context) .
         $content .
         "</div>";
}

sub link {
  my($self) = @_;

  $self -> page -> link . "/page-part/" . $self -> id;
}

sub can_PUT    { $_[0] -> page -> can_PUT    }
sub can_GET    { $_[0] -> page -> can_GET    }
sub can_DELETE { $_[0] -> page -> can_DELETE }

1;

__END__
