package OokOok::View::Mason;

use Moose;
use namespace::autoclean;

extends 'Catalyst::View::Mason2';

__PACKAGE__ -> config(
  plugins => [
    'HTMLFilters'
  ]
);

1;
