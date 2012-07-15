package OokOok::Role::Resource::HasEditions;
use Moose::Role;

has edition_resource_class => (
  is => 'rw',
  isa => 'Str',
  lazy => 1,
  default => sub {
    my($self) = @_;
    my $class = blessed $self;
    $class . 'Edition';
  },
);

sub edition {
  my($self) = @_;

  $self -> edition_resource_class -> new(
    c => $self -> c,
    source => $self -> source -> current_edition,
  );
}

1;
