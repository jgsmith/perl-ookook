use strict;
use warnings;
use Test::More;


use Catalyst::Test 'OokOok';
use OokOok::Controller::Theme;

ok( request('/theme')->is_success, 'Request should succeed' );
done_testing();
