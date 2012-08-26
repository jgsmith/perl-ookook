use utf8;
package OokOok::Schema::Result::TypefaceFontVersion;

=head1 NAME

OokOok::Schema::Result::TypefaceFontVersion

=cut

use OokOok::ResultVersion;
use namespace::autoclean;

is_publishable;

prop weight => (
  data_type => 'varchar',
  default_value => 'normal',
  is_nullable => 0,
  size => 32
);

prop style => (
  data_type => 'varchar',
  default_value => 'normal',
  is_nullable => 0,
  size => 64
);

owns_many typeface_font_files => 'OokOok::Schema::Result::TypefaceFontFile';

1;
