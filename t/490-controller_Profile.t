use strict;
use warnings;
use Test::More;

BEGIN {
  $ENV{'OOKOOK_CONFIG_LOCAL_SUFFIX'} = "testing";
}

use lib 't/lib';
use OokOok::Test::REST;
use OokOok::Controller::Profile;

ok( request('/profile')->is_success, 'Request should succeed' );
done_testing();
