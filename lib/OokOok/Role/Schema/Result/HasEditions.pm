package OokOok::Role::Schema::Result::HasEditions;

use Moose::Role;

with 'OokOok::Role::Schema::Result::UUID';

=head1 NAME

OokOok::Role::Schema::Result::HasEditions

=head1 SYNOPSIS

 package OokOok::Schema::Result::Thing;

 use Moose;
 extends 'DBIx::Class::Core';
 with 'OokOok::Role::Schema::Result::HasEditions';

=head1 DESCRIPTION

This role provides support for objects that have editions in OokOok. 

The class that uses this role must provide an C<editions> function that
represents a 'has many' relationship with the edition objects.

=cut

#requires 'editions';

=head1 AUGMENTATIONS

The following methods are overridden or otherwise altered in functionality.

=head2 insert

=cut

#use Data::UUID ();
#use DateTime;
#
#{
#  my $ug = Data::UUID -> new;
#
#  before insert => sub {
#    my($self) = @_;
#
#    my $uuid = substr($ug -> create_b64(),0,20);
#    $uuid =~ tr{+/}{-_};
#    $self -> uuid($uuid);
#    #$self -> created_on(DateTime->now);
#  };
#}

after insert => sub {
  $_[0] -> create_related('editions', {});
  $_[0];
};

=head2 delete

=cut

before delete => sub {
  if(grep { $_ -> is_closed } $_[0] -> editions) {
    die "Unable to delete with closed editions";
  }
};

=head1 METHODS

The following methods are added to the class.

=head2 edition_for_date

=cut

sub edition_for_date {
  my($self, $date) = @_;

  my $q = $self -> editions;

  return $self -> _apply_date_constraint($q, "", $date) -> first;
}

=head2 current_edition

=cut

sub current_edition { $_[0] -> edition_for_date; }

=head2 last_frozen_on

Returns the date of the most recently frozen edition.

=cut

sub last_closed_on {
  my($self) = @_;

  my $last = $self -> editions -> search(
    { 'closed_on' => { '!=', undef } },
    { order_by => { -desc => 'id' }, rows => 1 }
  )->first;

  if($last) {
    return $last->closed_on;
  }
}

=head2 relation_for_date

Given the relation for $comp, we want the row from ${comp}_version that
is closest to the $date.

$comp -> versions -> search({
  "edition.closed_on" => { '<=' => $date }
}, {
  join => [ 'edition' ],
  order_by => { -desc => 'id' }, 
  rows => 1
})

=cut

sub relation_for_date {
  my($self, $relation, $uuid, $date) = @_;

  my $join_table = $self -> editions -> result_source -> from;
  my $target_key = $self -> result_source -> from . "_id";

  my $q = $self -> result_source -> schema -> resultset($relation);

  my $comp = $q -> find({ uuid => $uuid, $target_key => $self -> id });

  return unless $comp;

  $q = $self -> result_source -> schema -> resultset($relation . "Version");
  $q = $q -> search({ $comp->result_source->from . "_id" => $comp -> id });

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

sub editions_count { $_[0] -> editions -> count + 0 - 1; }

1;

__END__

