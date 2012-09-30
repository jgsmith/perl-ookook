package OokOok::Declare::Meta::Table;

# ABSTRACT: Meta information for table classes

use Moose::Role;
use namespace::autoclean;

has foreign_key => (
  is => 'rw',
  isa => 'Str',
);

1;

