package OokOok::Formatter::Markdown;

use Moose;
use namespace::autoclean;
use Text::Markdown qw(markdown);

sub format { markdown $_[1] }

1;
