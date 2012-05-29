package OokOok::Role::Schema::Result::Editions;

use Moose::Role;

use Data::UUID;
use DateTime;

{
  my $ug = Data::UUID -> new;

  before insert => sub {
    my($self) = @_;

    my $uuid = substr($ug -> create_b64(),0,20);
    $uuid =~ tr{+/}{-_};
    $self -> uuid($uuid);
    $self -> created_on(DateTime->now);
  };
}

after insert => sub {
  $_[0] -> create_related('editions', {});
  $_[0];
};

before delete => sub {
  if(grep { $_ -> is_frozen } $_[0] -> editions) {
    die "Unable to delete with published editions";
  }
};

sub edition_for_date {
  my($self, $date) = @_;

  my $q = $self -> editions;

  return $self -> _apply_date_constraint($q, "", $date) -> first;
}

sub current_edition { $_[0] -> edition_for_date; }

sub _apply_date_constraint {
  my($self, $q, $join, $date) = @_;

  if($join ne "") { 
    $q = $q -> search(
      {},
      { join => [ $join ] }
    );
    $join = $join . ".";
  }

  if($date) {
    if(ref $date) {
      $date = $self -> result_source -> schema -> storage -> datetime_parser -> format_datetime($date);
    }
    $q = $q -> search(
      { $join."frozen_on" => { '<=' => $date } },
    );
  }

  $q = $q -> search(
    {},
    { order_by => { -desc => $join."id" } }
  );

  return $q;
}

1;

__END__
