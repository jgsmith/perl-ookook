use MooseX::Declare;

# PODNAME: OokOok::Declare::Base::TableEdition

class OokOok::Declare::Base::TableEdition 
      extends OokOok::Declare::Base::Table {

  use DateTime;
  use OokOok::Exception;

  before insert {
    $self -> created_on(DateTime -> now);
  }

  method is_closed { defined $self -> closed_on }

  # closing an edition indicates that the edition's associated data
  # cannot be modified - it's frozen, but not published (yet)
  method close {
    return if $self -> is_closed;

    my $next = $self -> copy({
      created_on => DateTime -> now,
      closed_on => undef
    });

    $self -> update({
      closed_on => DateTime -> now
    });

    return $next;
  }

  method is_published {
    defined($self -> published) &&
    defined($self -> published -> [0])
  }

  # a closed edition that has no succeeding closed edition that is published
  # may be published. The currently published edition will be marked as no
  # longer published
  method publish {
    return unless $self -> is_closed;

    # now check succeeding editions
    return if 0 < $self -> source -> select( {
      'me.closed_on' => { '!=' => undef, '>' => $self -> closed_on },
      'me.published_for' => { '!=' => undef },
    } ) -> count;

    my $timecut = DateTime->now -> add(seconds => 1) -> iso8601;
    my $current = $self -> source -> select( {
      'me.published_for' => { '@>' => $timecut },
    } );
    $current -> update({
      published_for => [ $current->published_for->[0], $timecut ],
    });
    $self -> update({
      published_for => [ $timecut, ],
    });
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
        closed_on => undef
      });
    }
    else {
      $self -> owner -> create_related(
        $self -> owner -> edition_relation,
        {}
      );
    }
  }

  before update {
    if($self -> is_closed) {
      $self -> discard_changes;
      OokOok::Exception::PUT->bad_request(
        message => "Unable to modify a closed edition"
      );
    }
  }
}

__END__
