package OokOok::Resource::ThemeSnippet;
use OokOok::Resource;

use namespace::autoclean;

has '+source' => (
  isa => 'OokOok::Model::DB::ThemeSnippet',
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

sub can_PUT {
  my($self) = @_;

  $self -> theme -> can_PUT;
}

sub render {
  my($self, $context) = @_;

  my $proc = OokOok::Template::Processor -> new(
    c => $self -> c,
  );

  my $doc = $proc -> parse( $self -> content );
  my $name = $self -> name;
  $name =~ s{[^-A-Za-z0-9_]+}{-}g;
  $name =~ s{-+}{-}g;
  return "<div class='snippet snippet-$name'>" .
    $doc -> render($context) .
    "</div>";
}

1;
