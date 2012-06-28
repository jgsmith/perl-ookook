package OokOok::Role::Schema::Result::Version;

use Moose::Role;

override update => sub {
  my($self, $columns) = @_;

  $self -> set_inflated_columns($columns) if $columns;

  my %dirty_columns = $self -> get_dirty_columns;

  if($dirty_columns{$self -> edition -> result_source -> from . "_id"}) {
    $self -> discard_changes();
    die "Unable to update an object's edition";
  }
  if($dirty_columns{$self -> owner -> result_source -> from . "_id"}) {
    $self -> discard_changes();
    die "Unable to update an object's edition";
  }

  if(!keys %dirty_columns) {
    return $self; # nothing to update
  }

  if($self -> edition -> is_closed) {
    my $new = $self -> duplicate_to_current_edition;
    $self -> discard_changes();
    return $new -> update(\%dirty_columns);
  }
  else {
    return super;
  }
};

sub duplicate_to_current_edition {
  my($self, $current_edition) = @_;

  my $edition_id_key = $self -> edition -> result_source -> from . "_id";
  my $owner_id_key = $self -> owner -> result_source -> from . "_id";

  $current_edition ||= $self -> edition -> owner -> current_edition;
  if($current_edition -> is_closed) {
    $self -> discard_changes();
    die "Current instance is closed. Unable to duplicate object for changes";
  }

  if($self -> result_source -> resultset -> search({ $edition_id_key => $current_edition -> id, $owner_id_key => $self -> owner -> id })->count > 0) {
    $self -> discard_changes();
    die "Current instance already has the object";
  }

  return $self -> copy({
    $edition_id_key => $current_edition -> id
  });
}

before delete => sub {
  if($_[0] -> edition -> is_closed) {
    die "Unable to modify a closed instance";
  }
};

1;

__END__
