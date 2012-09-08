#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

BEGIN {
  $ENV{'OOKOOK_CONFIG_LOCAL_SUFFIX'} = "testing";
}

use Catalyst::Test 'OokOok';

ok( request('/')->is_success, 'Request should succeed' );

done_testing();
