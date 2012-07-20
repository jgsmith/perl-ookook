package OokOok::Formatter::HTML;

use Moose;
use namespace::autoclean;

# we return HTML, so we just pass things through as-is
sub format { $_[1] }

1;
