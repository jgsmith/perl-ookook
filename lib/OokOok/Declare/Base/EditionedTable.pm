use MooseX::Declare;

# PODNAME: OokOok::Declare::Base::EditionedTable

# ABSTRACT: Base class for editioned resource tables

class OokOok::Declare::Base::EditionedTable extends OokOok::Declare::Base::Table {
  use DateTime::Format::ISO8601;
  use OokOok::Exception;

  after insert {
    $self -> create_related('editions', {});
    $self;
  };

  before delete {
    if(grep { $_ -> is_closed } $self -> editions) {
      OokOok::Exception::DELETE -> bad_request(
        message => "Unable to delete with closed editions"
      );
    }
  }

  method edition_for_date ($date?) {
    my $q = $self -> editions;
    $self -> _apply_date_constraint($q, "", $date) -> first;
  }

  *version_for_date = \&edition_for_date;

  method has_public_edition {
    defined $self -> last_closed_on;
  }

  method current_edition { $self -> edition_for_date }

  *current_version = \&current_edition;

  # the edition that includes now should be unclosed, and thus
  # the most recently closed/published edition
  method last_closed_on {
    my $last = $self -> edition_for_date(DateTime -> now);

    if($last) {
      return $last -> closed_on;
    }
  }

=method has_permission ($user, Str $permission)

Returns true if the user has the appropriate permission for the given board.

If the editioned resource is locked, then the permission has C<locked.>
prepended. Otherwise, C<unlocked.> is prepended.

See L<OokOok::Schema::Result::BoardRank> and
L<OokOok::Schema::Result::User> for more information.

=cut

  method has_permission (Object $user, Str $permission) {
    if($self -> is_locked) {
      return $user -> has_permission($self -> board, "locked." . $permission);
    }
    else {
      return $user -> has_permission($self -> board, "unlocked." . $permission);
    }
  }

  method relation_for_date (Str $relation, Str $uuid, $date?) {
    my $join_table = $self -> editions -> result_source -> from;
    my $target_key = $self -> result_source -> from . "_id";

    my $q = $self -> result_source -> schema -> resultset($relation);

    my $comp = $q -> find({ uuid => $uuid, $target_key => $self -> id });

    return unless $comp;

    $q = $self -> result_source -> schema -> resultset($relation . "Version");
    $q = $q -> search({ $comp->result_source -> from . "_id" => $comp -> id });
    return $self -> _apply_date_constraint($q, $join_table, $date) -> first;
  }

  method _apply_date_constraint ($q, $join, $date?) {
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
      else {
        $date = $self -> result_source -> schema -> storage -> datetime_parser -> format_datetime(
          DateTime::Format::ISO8601 -> parse_datetime($date)
        );
      }
      $q = $q -> search(
        { "me.published_for" => { '@>' => \"'$date'::timestamp" } },
      );
    }

    $q = $q -> search(
      {},
      { order_by => { -desc => "me.id" } }
    );

    return $q;
  }

  method editions_count { $self -> editions -> count + 0 - 1; }
}
