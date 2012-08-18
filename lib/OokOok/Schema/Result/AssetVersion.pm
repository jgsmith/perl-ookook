use utf8;
package OokOok::Schema::Result::AssetVersion;

=head1 NAME

OokOok::Schema::Result::AssetVersion

=cut

use OokOok::ResultVersion;
use namespace::autoclean;

is_publishable;

prop size => (
  data_type => 'integer',
  is_nullable => 1,
);

prop filename => (
  data_type => 'char',
  is_nullable => 1,
  size => 20,
  unique => 1,
);

prop name => (
  data_type => 'varchar',
  is_nullable => 0,
  size => 255,
);

prop type => (
  data_type => 'varchar',
  is_nullable => 1,
  size => 64,
);

prop metadata => (
  data_type => 'text',
  is_nullable => 1,
);

1;
