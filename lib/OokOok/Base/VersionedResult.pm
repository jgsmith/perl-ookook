package OokOok::Base::VersionedResult;

use Moose;
extends 'OokOok::Base::Result';

use namespace::autoclean;

override delete => sub {
  my($self) = @_;

  # we want to reset the current version if we have prior versions
  my $cv = $self -> current_version;
  if($cv -> edition -> is_closed) {
    return 0;
  }

  return 0 unless $cv -> delete;
  if($self -> versions -> count == 0) {
    return super;
  }
  return 1;
};

around insert => sub {
  my $orig = shift;
  my $self = shift;

  my $new = $self -> $orig(@_);

  $new -> create_related('versions', {
    edition => $self -> owner -> current_edition,
  });
  $new;
};

override update => sub {
  my($self, $columns) = @_;

  $self -> set_inflated_columns($columns) if $columns;

  my %dirty_columns = $self -> get_dirty_columns;

  if($dirty_columns{$self -> owner -> result_source -> from."_id"}) {
    $self -> discard_changes;
    die "Unable to update a versioned object's owner";
  }
  if($dirty_columns{'uuid'}) {
    $self -> discard_changes;
    die "Unable to update the uuid of a versioned object";
  }

  if(!keys %dirty_columns) {
    return $self;
  }

  super;
};

sub current_version {
  $_[0] -> versions -> search({},
    { order_by => { -desc => 'id' }, rows => 1 }
  ) -> first
}

sub version_for_date {
  my($self, $date) = @_;

  if(!defined $date or !$date) { return $self -> current_version; }

  if(ref $date) {
    $date = $self -> result_source -> schema -> storage -> datetime_parser -> format_datetime($date);
  }

  my $join = "edition"; #$self -> owner -> editions -> result_source -> from;

  $self -> search_related( versions =>
    {
      $join.".closed_on" => { '<=' => $date },
    },
    {
      join => [$join],
      order_by => { -desc => 'me.id' }
    }
  ) -> first;
}

1;
