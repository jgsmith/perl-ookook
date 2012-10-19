use MooseX::Declare;

# PODNAME: OokOok::Declare::Base::TableVersion

# ABSTRACT: Base class for results attached to a versioned result

class OokOok::Declare::Base::TableVersion extends OokOok::Declare::Base::Table {

  method is_published {
    defined($self -> published_for) && 
    defined($self -> published_for -> start)
  }

  override update (HashRef $columns?) {
    my $current_published_for = $self -> published_for;

    $self -> set_inflated_columns($columns) if $columns;

    my %dirty_columns = $self -> get_dirty_columns;

    if($dirty_columns{$self -> edition -> result_source -> from . "_id"}) {
      if($self -> can("status") && $self -> status <= 0) {
        $self -> discard_changes();
        OokOok::Exception::PUT -> forbidden(
          message => "Unable to update an object's edition"
        );
      }
    }
    if($dirty_columns{$self -> owner -> result_source -> from . "_id"}) {
      $self -> discard_changes();
      OokOok::Exception::PUT -> forbidden(
        message => "Unable to update an object's owner"
      );
    }

    if(!keys %dirty_columns) {
      return $self; # nothing to update
    }

    if($self -> edition -> is_closed) {
      if(1 == keys %dirty_columns && exists($dirty_columns{published_for}) && defined($dirty_columns{published_for})) {
        if($self -> can("status") && $self -> status > 0) {
          $self -> discard_changes();
          OokOok::Exception::PUT -> forbidden(
            message => "Unable to modify the publication dates of an unapproved resource"
          );
        }
        my $pf = OokOok::Util::DB::inflate_tsrange(${$dirty_columns{published_for}});   
        if(defined($current_published_for)) {
          if(defined $current_published_for -> end && $current_published_for -> end -> is_finite) {
            $self -> discard_changes;
            OokOok::Exception::PUT -> forbidden(
              message => "Unable to modify the publication dates of a published resource"
            );
          }
          if($current_published_for -> start ne $pf->start) {
            $self -> discard_changes;
            OokOok::Exception::PUT -> forbidden(
              message => "Unable to modify the publication dates of a published resource"
            );
          }
          if($pf -> end -> is_finite && $pf -> end < $pf -> start) {
            $self -> discard_changes;
            OokOok::Exception::PUT -> forbidden(
              message => "Unable to modify the publication dates of a published resource"
            );
          }
        }
        return super;  
      }
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

    my $most_recent = $self -> result_source -> resultset -> search({ 
      $edition_id_key => $current_edition -> id, 
      $owner_id_key => $self -> owner -> id
    })->first;

    if($most_recent) {
      return $most_recent;
      $self -> discard_changes;
      OokOok::Exception::PUT -> bad_request(
        message => "Another copy already exists in the working edition. Unable to duplicate object for changes."
      );
    }

    my $overrides = {
      $edition_id_key => $current_edition -> id,
      published_for => undef,
    };

    if($self -> can('status')) {
      $overrides->{status} = 100; # 100 - Draft, <= 0 - Published
    }

    return $self -> copy($overrides);
  }

  before delete {
    if($self -> edition -> is_closed) {
      OokOok::Exception::DELETE -> forbidden(
        message => "Unable to modify a closed instance"
      );
    }
  }
}
