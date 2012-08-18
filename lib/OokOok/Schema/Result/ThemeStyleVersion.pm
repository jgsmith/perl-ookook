use utf8;
package OokOok::Schema::Result::ThemeStyleVersion;

=head1 NAME

OokOok::Schema::Result::ThemeStyleVersion

=cut

use OokOok::ResultVersion;
use namespace::autoclean;

is_publishable;

prop name => (
  data_type => 'varchar',
  default_value => '',
  is_nullable => 0,
  size => 255,
);

prop styles => (
  data_type => 'text',
  is_nullable => 0,
  default_value => '',
);

1;
