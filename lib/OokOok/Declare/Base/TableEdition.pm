use MooseX::Declare;

# PODNAME: OokOok::Declare::Base::TableEdition

# ABSTRACT: Base class for resource edition tables

class OokOok::Declare::Base::TableEdition 
      extends OokOok::Declare::Base::Table {

  use DateTime;
  use DateTime::Span;
  use OokOok::Exception;

  before insert {
    $self -> created_on(DateTime -> now);
  }

  method is_closed { defined($self -> closed_on); }

  method closed_on {
    defined($self -> published_for) ? $self -> published_for -> start : undef;
  }

  # closing an edition indicates that the edition's associated data
  # cannot be modified - it's published
  method close {
    return if $self -> is_closed;

    my $now = DateTime -> now;

    my $owner = $self -> owner;

    # we need to mark ourselves as available for publication after we
    # close off the previous edition, if there is one
    my $current = $self -> owner -> edition_for_date($now);

    if($current) {
      # close off current edition
      $current -> update({
        published_for => DateTime::Span -> from_datetimes(
          start => $current -> published_for -> start,
          before => $now
        ),
      });
    }

    my $next = $self -> copy({
      created_on => $now,
    });

    $self -> update({
      published_for => DateTime::Span -> from_datetimes(
        start => $now,
      ),
    });

    return $next;
  }

  method move_statused_resources ($next, $resources) {
    for my $resource (@$resources) {
      $self -> $resource -> search({
        status => { '>' => 0 }
      }) -> update_all({
        edition_id => $next -> id
      });
    }
  }

  method close_resources ($resources) {
    my $now = $self -> closed_on;
    for my $resource (@$resources) {
      for my $item ($self -> $resource) {
        my $ci = $item -> owner -> version_for_date($now);
        if($ci) {
          $ci -> update({
            published_for => DateTime::Span -> from_datetimes(
              start => $ci -> published_for -> start, 
              before => $now
            ),
          });
        }
        $item -> update({
          published_for => DateTime::Span -> from_datetimes(
            start => $now,
          ),
        });
      }
    }
  }

  before delete {
    if($self -> is_closed) {
      OokOok::Exception::DELETE -> forbidden(
        message =>  "Unable to delete a closed edition"
      );
    }
  };

  after delete {
    my $prev = $self -> owner -> current_edition;
  
    if($prev) {
      $prev -> copy({
        created_on => DateTime -> now,
        published_for => undef,
      });
    }
    else {
      $self -> owner -> create_related(
        $self -> owner -> edition_relation,
        {}
      );
    }
  }

  override update (HashRef $columns?) {
    if($self -> is_closed) {
      my $current_published_for = $self -> published_for;
      if(defined $current_published_for->start) {
        $self -> discard_changes;
        OokOok::Exception::PUT->bad_request(
          message => "Unable to modify a closed edition"
        );
      }
      $self -> set_inflated_columns($columns) if $columns;
      my %dirty_columns = $self -> get_dirty_columns;
      if(keys %dirty_columns > 1 || (keys %dirty_columns)[0] ne 'published_for') {
        $self -> discard_changes;
        OokOok::Exception::PUT->bad_request(
          message => "Unable to modify a closed edition"
        );
      }

      if($self -> published_for -> start ne $current_published_for -> start) {
        $self -> discard_changes;
        OokOok::Exception::PUT->bad_request(
          message => "Unable to modify a closed edition"
        );
      }
    }
    super;
  }
      
}
