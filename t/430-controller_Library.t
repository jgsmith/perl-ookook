use strict;
use warnings;
use Test::More;

BEGIN {
  $ENV{'OOKOOK_CONFIG_LOCAL_SUFFIX'} = "testing";
}

use Catalyst::Test 'OokOok';
use OokOok::Controller::Library;

ok( request('/library')->is_success, 'Request should succeed' );
done_testing();
