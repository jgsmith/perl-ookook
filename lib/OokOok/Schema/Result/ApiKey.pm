use utf8;
package OokOok::Schema::Result::ApiKey;

=head1 NAME

OokOok::Schema::Result::ApiKey

=cut

use OokOok::Result;
use namespace::autoclean;

prop token => (
  data_type => 'varchar',
  is_nullable => 0,
  size => 255,
);

prop token_secret => (
  data_type => 'varchar',
  is_nullable => 0,
  size => 255,
);

1;
