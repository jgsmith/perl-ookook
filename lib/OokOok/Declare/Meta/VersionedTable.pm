package OokOok::Declare::Meta::VersionedTable;

# ABSTRACT: Meta information for versioned table classes

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
