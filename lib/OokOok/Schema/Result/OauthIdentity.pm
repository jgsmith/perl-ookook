use utf8;
package OokOok::Schema::Result::OauthIdentity;

# ABSTRACT: information about a user's OAuth identity

use OokOok::Result;
use namespace::autoclean;

prop oauth_service_id => (
  data_type => 'integer',
  is_nullable => 1,
);

prop oauth_user_id => (
  data_type => 'varchar',
  is_nullable => 1,
  size => 128
);

prop screen_name => (
  data_type => 'varchar',
  is_nullable => 1,
  size => 255,
);

prop token => (
  data_type => 'varchar',
  is_nullable => 1,
  size => 255,
);

prop token_secret => (
  data_type => 'varchar',
  is_nullable => 1,
  size => 255,
);

prop profile_img_url => (
  data_type => 'varchar',
  is_nullable => 1,
  size => 255,
);

1;
