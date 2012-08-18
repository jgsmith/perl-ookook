package OokOok::Meta::ResultEdition;

use Moose::Role;
use namespace::autoclean;

has foreign_key => (
  is => 'rw',
  isa => 'Str',
);

1;

