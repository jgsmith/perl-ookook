use strict;
use warnings;
use Test::More;


use Catalyst::Test 'OokOok';
use OokOok::Controller::View;

ok( !request('/view')->is_success, 'Request should not succeed' );
done_testing();
