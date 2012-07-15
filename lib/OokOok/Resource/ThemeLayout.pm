package OokOok::Resource::ThemeLayout;

use OokOok::Resource;

belongs_to 'parent_layout' => 'OokOok::Resource::ThemeLayout', (
  is => 'rw',
  source => sub { $_[0] -> source_version -> parent_layout },
);

#
# For now, we place the rendering stuff here since it depends on the
# Catalyst context, which means we want to avoid putting it in the
# schema result class.
#
sub render {
  my($self, $content) = @_;

  my $layout = $self -> source_version;
  if($layout) {
    my $template = $layout -> content;
  }
  return '';
}

1;
