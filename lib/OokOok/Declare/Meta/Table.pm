package OokOok::Declare::Meta::Table;

use Moose::Role;
use namespace::autoclean;

has foreign_key => (
  is => 'rw',
  isa => 'Str',
);

1;

