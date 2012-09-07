use MooseX::Declare;

class OokOok::Base::VersionedResult extends OokOok::Base::Result {
  use DateTime::Format::ISO8601;
  use OokOok::Exception;

  override delete {
    # we want to reset the current version if we have prior versions
    my $cv = $self -> current_version;
    if(!$cv) {
      OokOok::Exception::DELETE -> bad_request(
        message => "No current version associated with resource"
      );
    }

    if($cv -> edition -> is_closed) {
      OokOok::Exception::DELETE -> forbidden(
        message => "Unable to delete a resource associated with a closed edition"
      );
    }

    $cv -> delete;
    $self -> get_from_storage;
    if($self -> versions -> count == 0) {
      return super;
    }
    return 1;
  }

  around insert (@args) {
    my $new = $self -> $orig(@args);

    $new -> create_related('versions', {
      edition => $self -> owner -> current_edition,
    });
    $new;
  }

  override update (HashRef $columns?) {
    $self -> set_inflated_columns($columns) if $columns;

    my %dirty_columns = $self -> get_dirty_columns;

    if($dirty_columns{$self -> owner -> result_source -> from."_id"}) {
      $self -> discard_changes;
      OokOok::Exception::PUT->forbidden(
        message => "Unable to update a versioned object's owner"
      );
    }
    if($dirty_columns{'uuid'}) {
      $self -> discard_changes;
      OokOok::Exception::PUT->forbidden(
        message => "Unable to update the uuid of a versioned object"
      );
    }

    if(!keys %dirty_columns) {
      return $self;
    }

    super;
  }

  method current_version {
    $self -> versions -> search({},
      { order_by => { -desc => 'id' }, rows => 1 }
    ) -> first
  }

  method version_for_date ($date?) {
    if(!defined $date or !$date) { return $self -> current_version; }

    if(ref $date) {
      $date = $self -> result_source -> schema -> storage -> datetime_parser -> format_datetime($date);
    }
    else {
      $date = $self -> result_source -> schema -> storage -> datetime_parser -> format_datetime(
        DateTime::Format::ISO8601 -> parse_datetime($date)
      );
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

}
