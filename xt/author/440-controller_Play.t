use strict;
use warnings;
use Test::More;
use HTTP::Request::Common;
use JSON;

BEGIN {
  $ENV{'OOKOOK_CONFIG_LOCAL_SUFFIX'} = "testing";
}

use OokOok::ForTesting::REST;
use OokOok::Controller::Play;

ok( !request('/p')->is_success, 'Request should not succeed' );

done_testing();
