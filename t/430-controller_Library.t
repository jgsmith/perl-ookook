use strict;
use warnings;
use Test::More;


use Catalyst::Test 'OokOok';
use OokOok::Controller::Library;

ok( request('/library')->is_success, 'Request should succeed' );
done_testing();
