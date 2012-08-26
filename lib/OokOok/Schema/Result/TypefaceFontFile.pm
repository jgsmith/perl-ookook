use utf8;
package OokOok::Schema::Result::TypefaceFontFile;

=head1 NAME

OokOok::Schema::Result::TypefaceFontFile

=cut

use OokOok::Result;
use namespace::autoclean;

prop filename => (
  data_type => 'char',
  is_nullable => 0,
  size => 20,
  unique => 1,
);

prop format => (
  data_type => 'varchar',
  is_nullable => 0,
  size => 16,
);

1;
