package OokOok::Base::ResultEdition;

use Moose;
extends 'OokOok::Base::Result';

use namespace::autoclean;
use DateTime;

before insert => sub {
  $_[0] -> created_on(DateTime -> now);
};

sub is_closed { defined $_[0] -> closed_on }

sub close {
  my($self) = @_;

  return if $self -> is_closed;

  my $next = $self -> copy({
    created_on => DateTime -> now,
    closed_on => undef
  });

  $self -> update({
    closed_on => DateTime -> now
  });

  return $next;
}

before delete => sub {
  if($_[0] -> is_closed) {
    die "Unable to delete a closed edition";
  }
};

after delete => sub {
  my($self) = @_;

  my $prev = $self -> owner -> current_edition;

  if($prev) {
    $prev -> copy({
      created_on => DateTime -> now,
      closed_on => undef
    });
  }
  else {
    $self -> owner -> create_related(
      $self -> owner -> edition_relation,
      {}
    );
  }
};

before update => sub {
  if($_[0] -> is_closed) {
    $_[0] -> discard_changes;
    die "Unable to modify a closed edition";
  }
};

1;

__END__
