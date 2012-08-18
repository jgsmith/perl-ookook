use utf8;
package OokOok::Schema::Result::ThemeLayoutVersion;

=head1 NAME

OokOok::Schema::Result::ThemeLayoutVersion

=cut

use OokOok::ResultVersion;
use namespace::autoclean;

is_publishable;

prop parent_layout_id => (
  data_type => 'integer',
  is_nullable => 1,
);

__PACKAGE__ -> belongs_to( parent_layout => 'OokOok::Schema::Result::ThemeLayout', 'parent_layout_id' );

prop theme_style_id => (
  data_type => 'integer',
  is_nullable => 1,
);

__PACKAGE__ -> belongs_to( theme_style => 'OokOok::Schema::Result::ThemeStyle', 'theme_style_id' );

prop internal_layout => (
  data_type => 'boolean',
  default_value => 0,
  is_nullable => 0,
);

prop name => (
  data_type => 'varchar',
  default_value => '',
  is_nullable => 0,
  size => 255,
);

prop layout => (
  data_type => 'text',
  is_nullable => 0,
  default_value => '',
);

1;
