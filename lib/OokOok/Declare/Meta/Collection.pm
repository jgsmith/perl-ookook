package OokOok::Declare::Meta::Collection;

# ABSTRACT: Provides meta-class info for REST collections

use Moose::Role;

use namespace::autoclean;

has resource_class => (
  is => 'rw',
  isa => 'Str',
);

has resource_model => (
  is => 'rw',
  isa => 'Str',
);

has resource_name => (
  is => 'rw',
  isa => 'Str',
);

1;
