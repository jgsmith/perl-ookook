package OokOok::Base::ResultEdition;

use Moose;
extends 'OokOok::Base::Result';

use namespace::autoclean;
use DateTime;

before insert => sub {
  $_[0] -> created_on(DateTime -> now);
};

sub is_closed { defined $_[0] -> closed_on }

# closing an edition indicates that the edition's associated data
# cannot be modified - it's frozen, but not published (yet)
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

# a closed edition that has no succeeding closed edition that is published
# may be published. The currently published edition will be marked as no longer
# published
sub publish {
  my($self) = @_;

  return unless $self -> is_closed;

  # now check succeeding editions
  return if 0 < $self -> source -> select( {
    'me.closed_on' => { '!=' => undef, '>' => $self -> closed_on },
    'me.published_for' => { '!=' => undef },
  } ) -> count;

  my $timecut = DateTime->now -> add(seconds => 1) -> iso8601;
  my $current = $self -> source -> select( {
    'me.published_for' => { '@>' => $timecut },
  } );
  $current -> update({
    published_for => [ $current->published_for->[0], $timecut ],
  });
  $self -> update({
    published_for => [ $timecut, ],
  });
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
