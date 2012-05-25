use strict;
use warnings;
use Test::More;


use Catalyst::Test 'OokOok';
use OokOok::Controller::Project;

ok( request('/project')->is_success, 'Request should succeed' );
done_testing();
