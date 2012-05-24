package OokOok::Event;
use Moose;
use namespace::autoclean;

has '_listeners' => (
  is => 'ro',
  isa => 'ArrayRef[CodeRef]',
  default => sub { [] },
);

sub addListener {
  my($self, $listener) = @_;

  push @{$self -> _listeners}, $listener;
}

sub fire {
  my $self = shift;

  for my $listener (@{$self->_listeners}) {
    $listener->(@_);
  }
}

1;

__END__
