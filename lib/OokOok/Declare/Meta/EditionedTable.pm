package OokOok::Declare::Meta::EditionedTable;

use Moose::Role;
use namespace::autoclean;

has edition_relation => (
  is => 'rw',
  isa => 'Str',
);

has foreign_key => (
  is => 'rw',
  isa => 'Str',
);

1;
