use strict;
use warnings;
use Test::More;

BEGIN {
  $ENV{'OOKOOK_CONFIG_LOCAL_SUFFIX'} = "testing";
}

BEGIN { use_ok 'OokOok::View::HTML' }

done_testing();
