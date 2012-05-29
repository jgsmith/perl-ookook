package OokOok::Role::Schema::Result::Edition;

use DateTime;
use Moose::Role;

requires 'owner';

before insert => sub {
  $_[0] -> created_on(DateTime->now);
};

sub is_frozen { defined $_[0] -> frozen_on; }

sub freeze {
  my($self) = @_;

  return if $self -> is_frozen;

  $self -> copy({
   created_on => DateTime -> now,
   frozen_on => undef
  });

  $self -> update({
    frozen_on => DateTime -> now
  });
}

before delete => sub {
  if($_[0] -> is_frozen) {
    die "Unable to delete a frozen instance";
  }
};

after delete => sub {
  my($self) = @_;

  my $prev = $self -> owner -> current_edition;

  if($prev) {
    $prev -> copy({
      created_on => DateTime -> now,
      frozen_on => undef
    });
  }
  else {
    $self -> owner -> create_related("editions", {});
  }
};

before update => sub {
  if($_[0] -> is_frozen) {
    $_[0] -> discard_changes();
    die "Unable to modify a frozen instance";
  }
};

1;

__END__
