use utf8;
package OokOok::Schema::Result::ThemeStyleVersion;

=head1 NAME

OokOok::Schema::Result::ThemeStyleVersion

=cut

use OokOok::ResultVersion;
use namespace::autoclean;

prop status => (
  data_type => 'integer',
  default_value => 0,
  is_nullable => 0,
);

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
