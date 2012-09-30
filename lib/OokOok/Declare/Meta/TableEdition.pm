package OokOok::Declare::Meta::TableEdition;

# ABSTRACT: Meta information for table edition classes

use Moose::Role;
use namespace::autoclean;

has foreign_key => (
  is => 'rw',
  isa => 'Str',
);

1;

