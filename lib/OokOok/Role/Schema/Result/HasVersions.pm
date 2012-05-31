package OokOok::Role::Schema::Result::HasVersions;

use Moose::Role;

use Data::UUID ();

{
  my $ug = Data::UUID -> new;
  before insert => sub {
    my($self) = @_;

    if($self -> edition -> is_frozen) {
      die "Unable to modify a frozen instance";
    }

    if(!$self -> uuid) {
      my $uuid = substr($ug->create_b64(),0,20);
      $uuid =~ tr{+/}{-_};
      $self -> uuid($uuid);
    }
  };
}

override update => sub {
  my($self, $columns) = @_;

  $self -> set_inflated_columns($columns) if $columns;

  my %dirty_columns = $self -> get_dirty_columns;

  if($dirty_columns{$self -> edition -> result_source -> from . "_id"}) {
    $self -> discard_changes();
    die "Unable to update an object's instance";
  }

  if(!keys %dirty_columns) {
    return $self; # nothing to update
  }

  if($self -> edition -> is_frozen) {
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

  $current_edition ||= $self -> edition -> owner -> current_edition;
  if($current_edition -> is_frozen) {
    $self -> discard_changes();
    die "Current instance is frozen. Unable to duplicate object for changes";
  }

  if($self -> result_source -> resultset -> search({ $edition_id_key => $current_edition -> id, uuid => $self -> uuid })->count > 0) {
    $self -> discard_changes();
    die "Current instance already has the object";
  }

  return $self -> copy({
    $edition_id_key => $current_edition -> id
  });
}

before delete => sub {
  if($_[0] -> edition -> is_frozen) {
    die "Unable to modify a frozen instance";
  }
};

1;

__END__
