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

has_a 'parent_layout' => 'OokOok::Resource::ThemeLayout', (
  is => 'rw',
  source => sub { $_[0] -> source_version -> parent_layout },
);

has_a 'theme_style' => 'OokOok::Resource::ThemeStyle', (
  is => 'rw',
  source => sub { $_[0] -> source_version -> theme_style },
);

prop id => (
  is => 'ro',
  type => 'Str',
  source => sub { $_[0] -> source -> uuid },
);

prop name => (
  is => 'rw',
  required => 1,
  type => 'Str',
  source => sub { $_[0] -> source_version -> name },
);

prop layout => (
  is => 'rw',
  type => 'Str',
  required => 1,
  source => sub { $_[0] -> source_version -> layout },
);

sub can_PUT {
  my($self) = @_;

  $self -> theme -> can_PUT;
}

sub stylesheets {
  my($layout) = @_;

  my @stylesheets;
  while($layout) {
    my $s = $layout -> theme_style;
    if($s) {
      push @stylesheets, $s -> id;
    }
    $layout = $layout -> parent_layout;
  } 
  return reverse @stylesheets;
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
    # now load in taglibs and prefixes

    my %ns;
    for my $lib ($self -> theme -> libraries) {
      my $prefix = $lib -> prefix;
      my $uin = "uin:uuid:" . $lib -> id;
      $ns{$prefix} = $uin;
    }

    my $processor = OokOok::Template::Processor -> new(
      c => $self -> c,
      namespaces => \%ns,
    );

    my $ret = $processor -> parse($template) -> render($context);

    # now worry about parent layout
    if($self -> parent_layout) {
      $context = $context -> localize;
      $context -> set_var(content => $ret);
      return $self -> parent_layout -> render($context);
    }
    else {
      return $ret;
    }
  }
  return "<p>Layout " . $self -> source_version -> name . "</p>";
}

1;
