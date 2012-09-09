use utf8;
package OokOok::Schema::Result::ApiKey;

# ABSTRACT: ApiKey database row

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
