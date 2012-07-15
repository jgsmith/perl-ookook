use strict;
use warnings;
use Test::More;

BEGIN {
  $ENV{'OOKOOK_CONFIG_LOCAL_SUFFIX'} = "testing";
}

use lib 't/lib';
use OokOok::Test::REST;
use OokOok::Controller::Theme;

ok( request('/theme')->is_success, 'Request should succeed' );
done_testing();
