use strict;
use warnings;

use OokOok;

my $app = OokOok->apply_default_middlewares(OokOok->psgi_app);
$app;

