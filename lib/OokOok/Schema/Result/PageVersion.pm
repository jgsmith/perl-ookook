use utf8;
package OokOok::Schema::Result::PageVersion;

=head1 NAME

OokOok::Schema::Result::PageVersion

=cut

use OokOok::ResultVersion;
use namespace::autoclean;

is_publishable;

prop layout => (
  data_type => 'char',
  is_nullable => 1,
  size => 20,
);

prop slug => (
  data_type => 'varchar',
  is_nullable => 1,
  default_value => '',
  size => 255,
);

prop parent_page_id => (
  data_type => 'integer',
  is_nullable => 1,
);

__PACKAGE__ -> belongs_to( 'parent_page' => 'OokOok::Schema::Result::Page', 'parent_page_id');

prop title => (
  data_type => 'varchar',
  is_nullable => 0,
  default_value => '',
  size => 255,
);

prop primary_language => (
  data_type => 'varchar',
  is_nullable => 1,
  size => 32,
);

prop description => (
  data_type => 'text',
  is_nullable => 1,
);

owns_many page_parts => 'OokOok::Schema::Result::PagePart';

sub render {
  my($self, $c) = @_;

  my $edition = $c -> stash -> {edition} || $self -> edition;
  my $layout = $edition -> layout($self -> layout);
  if($layout) {
    return $layout -> render($c->stash, $self);
  }

  return '';
}

1;
