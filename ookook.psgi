use strict;
use warnings;

use lib './lib';
use Plack::Builder;
use OokOok;

my $app = OokOok->apply_default_middlewares(OokOok->psgi_app(@_));

builder {
  enable_if { $_[0] -> {REMOTE_ADDR} eq '127.0.0.1' }
    "Plack::Middleware::ReverseProxy";
  $app;
};
