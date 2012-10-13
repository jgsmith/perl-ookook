package OokOok::Declare::Meta::TableEdition;

# ABSTRACT: Meta information for table edition classes

use Moose::Role;
use namespace::autoclean;

has foreign_key => (
  is => 'rw',
  isa => 'Str',
);

has versioned_resources => (
  is => 'rw',
  isa => 'ArrayRef',
  default => sub { [] },
  lazy => 1,
);

sub add_versioned_resource {
  my($self, $r) = @_;

  push @{$self -> versioned_resources}, $r;
}

sub get_versioned_resources { @{$_[0] -> versioned_resources} }

1;

