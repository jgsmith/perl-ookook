package OokOok::Resource::ThemeLayout;

use OokOok::Resource;
use OokOok::Template::Processor;
use OokOok::Template::Document;
use OokOok::Template::Context;

use namespace::autoclean;

has '+source' => (
  isa => 'OokOok::Model::DB::ThemeLayout',
);

belongs_to 'theme' => 'OokOok::Resource::Theme', (
  is => 'ro',
  required => 1,
  source => sub { $_[0] -> source -> theme },
);

belongs_to 'parent_layout' => 'OokOok::Resource::ThemeLayout', (
  is => 'rw',
  source => sub { $_[0] -> source_version -> parent_layout },
);

prop id => (
  is => 'ro',
  type => 'Str',
  source => sub { $_[0] -> source -> uuid },
);

prop name => (
  is => 'rw',
  type => 'Str',
  source => sub { $_[0] -> source_version -> name },
);

prop layout => (
  is => 'rw',
  type => 'Str',
  source => sub { $_[0] -> source_version -> layout },
);

sub can_PUT {
  my($self) = @_;

  $self -> theme -> can_PUT;
}

#
# For now, we place the rendering stuff here since it depends on the
# Catalyst context, which means we want to avoid putting it in the
# schema result class.
#
sub render {
  my($self, $context) = @_;

  my $layout = $self -> source_version;
  if($layout) {
    my $template = $layout -> layout;
    my $processor = OokOok::Template::Processor -> new(
      c => $self -> c,
    );
    $processor -> register_taglib('OokOok::Template::TagLibrary::Core');
    my $doc = $processor -> parse($template);
    return $doc -> render($context);
  }
  return "<p>Layout " . $self -> source_version -> name . "</p>";
}

1;
