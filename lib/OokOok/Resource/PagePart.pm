package OokOok::Resource::PagePart;
use OokOok::Resource;

prop title => (
  required => 1,
  max_length => 64,
  type => 'Str',
  source => sub { $_[0] -> source -> name },
);

prop content => (
  required => 0,
  type => 'Str',
  deep => 1,
);

belongs_to "page" => "OokOok::Resource::Page", (
  is => 'ro',
  required => 1,
);

sub render {
  my($self, $context) = @_;

  my $proc = OokOok::Template::Processor -> new(
    c => $self -> c,
  );

  # handle taglib registration based on page type and such
  my $doc = $proc -> parse($self -> content);

  $doc -> render($context);
}

1;

__END__
