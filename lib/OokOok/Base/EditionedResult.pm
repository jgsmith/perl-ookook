package OokOok::Base::EditionedResult;

use Moose;
extends 'OokOok::Base::Result';

use namespace::autoclean;

after insert => sub {
  $_[0] -> create_related('editions', {});
  $_[0];
};

before delete => sub {
  my($self) = @_;
  if(grep { $_ -> is_closed } $self -> editions) {
    die "Unable to delete with closed editions";
  }
};

sub edition_for_date {
  my($self, $date) = @_;

  my $q = $self -> editions;
  $self -> _apply_date_constraint($q, "", $date) -> first;
}

*version_for_date = \&edition_for_date;

sub has_public_edition {
  my($self) = @_;

  0 < $self->editions->search(
    { 'closed_on' => { '!=', undef } },
  ) -> count;
}

sub current_edition { $_[0] -> edition_for_date }

*current_version = \&current_edition;

sub last_closed_on {
  my($self) = @_;

  my $last = $self -> editions -> search(
    { 'closed_on' => { '!=', undef } },
    { order_by => { -desc => 'id' }, rows => 1 }
  ) -> first;

  if($last) {
    return $last -> closed_on;
  }
}

sub relation_for_date {
  my($self, $relation, $uuid, $date) = @_;

  my $join_table = $self -> editions -> result_source -> from;
  my $target_key = $self -> result_source -> from . "_id";

  my $q = $self -> result_source -> schema -> resultset($relation);

  my $comp = $q -> find({ uuid => $uuid, $target_key => $self -> id });

  return unless $comp;

  $q = $self -> result_source -> schema -> resultset($relation . "Version");
  $q = $q -> search({ $comp->result_source -> from . "_id" => $comp -> id });
  return $self -> _apply_date_constraint($q, $join_table, $date) -> first;
}

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
      { $join."closed_on" => { '<=' => $date } },
    );
  }

  $q = $q -> search(
    {},
    { order_by => { -desc => "me.id" } }
  );

  return $q;
}

sub editions_count {
  my($self) = @_;
  $self -> editions -> count + 0 - 1;
}

1;
