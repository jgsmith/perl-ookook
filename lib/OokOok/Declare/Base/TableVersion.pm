use MooseX::Declare;

# PODNAME: OokOok::Declare::Base::TableVersion

# ABSTRACT: Base class for results attached to a versioned result

class OokOok::Declare::Base::TableVersion extends OokOok::Declare::Base::Table {

  override update (HashRef $columns?) {
    $self -> set_inflated_columns($columns) if $columns;

    my %dirty_columns = $self -> get_dirty_columns;

    if($dirty_columns{$self -> edition -> result_source -> from . "_id"}) {
      if($self -> status <= 0) {
        $self -> discard_changes();
        OokOok::Exception::PUT -> forbidden(
          message => "Unable to update an object's edition"
        );
      }
    }
    if($dirty_columns{$self -> owner -> result_source -> from . "_id"}) {
      $self -> discard_changes();
      OokOok::Exception::PUT -> forbidden(
        message => "Unable to update an object's edition"
      );
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
  }

  method duplicate_to_current_edition (Object $current_edition?) {
    my $edition_id_key = $self -> edition -> result_source -> from . "_id";
    my $owner_id_key = $self -> owner -> result_source -> from . "_id";

    $current_edition ||= $self -> edition -> owner -> current_edition;
    if($current_edition -> is_closed) {
      $self -> discard_changes;
      OokOok::Exception::PUT -> bad_request(
        message => "Current instance is closed. Unable to duplicate object for changes"
      );
    }

    my $others = $self -> result_source -> resultset -> search({ 
      $edition_id_key => $current_edition -> id, 
      $owner_id_key => $self -> owner -> id 
    })->count;

    if($others) {
      $self -> discard_changes;
      OokOok::Exception::PUT -> bad_request(
        message => "Another copy already exists in the working edition. Unable to duplicate object for changes."
      );
    }

    return $self -> copy({
      $edition_id_key => $current_edition -> id,
      status => 100, # 100 - Draft, <= 0 - Published
    });
  }

  before delete {
    if($self -> edition -> is_closed) {
      OokOok::Exception::DELETE -> forbidden(
        message => "Unable to modify a closed instance"
      );
    }
  }
}
