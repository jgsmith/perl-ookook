package OokOok::Role::Schema::Result::HasVersions;

use Moose::Role;

use Data::UUID ();

{
  my $ug = Data::UUID -> new;
  around insert => sub {
    my $orig = shift;
    my $self = shift;

    if(!$self -> uuid) {
      my $uuid = substr($ug->create_b64(),0,20);
      $uuid =~ tr{+/}{-_};
      $self -> uuid($uuid);
    }

    my $new = $self -> $orig(@_);

    $new -> create_related('versions', {
      edition => $new -> owner -> current_edition,
    });
    $new;
  };
}

override update => sub {
  my($self, $columns) = @_;

  $self -> set_inflated_columns($columns) if $columns;

  my %dirty_columns = $self -> get_dirty_columns;

  if($dirty_columns{$self -> owner -> result_source -> from . "_id"}) {
    $self -> discard_changes();
    die "Unable to update a versioned object's owner";
  }
  if($dirty_columns{"uuid"}) {
    $self -> discard_changes();
    die "Unable to update the uuid of a versioned object";
  }

  if(!keys %dirty_columns) {
    return $self; # nothing to update
  }

  super;
};

sub current_version {
  my($self) = @_;

  $self -> versions -> search({},
    { order_by => { -desc => 'id' }, rows => 1 }
  ) -> first;
}

sub version_for_date {
  my($self, $date) = @_;

  if(!defined $date or !$date) { return $self -> current_version; }

  if(ref $date) {
    $date = $self -> result_source -> schema -> storage -> datetime_parser -> format_datetime($date);
  }

  my $join = $self -> owner -> editions -> result_source -> from;

  $self -> search_related('versions',
    { 
      $join.".closed_on" => { '<=' =>  $date},
    },
    { 
      join => [$join],
      order_by => { -desc => 'me.id' }
    }
  ) -> first;
}

1;

__END__
