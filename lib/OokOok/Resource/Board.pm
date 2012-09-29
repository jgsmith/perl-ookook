use OokOok::Declare;

# PODNAME: OokOok::Resource::Board

# ABSTRACT: REST board resource

resource OokOok::Resource::Board {

  prop name => (
    required => 1,
    type => 'Str',
    source => sub { $_[0] -> source -> name },
    maps_to => 'title',
  );

  prop id => (
    is => 'ro',
    type => 'Str',
    maps_to => 'id',
    source => sub { $_[0] -> source -> uuid },
  );

  prop permissions => (
    is => 'rw',
    type => 'HashRef',
    permission => 'board.admin',
    source => sub { $_[0] -> source -> permissions },
  );

  has_many 'board_members' => 'OokOok::Resource::BoardMember', (
    is => 'ro',
    source => sub { $_[0] -> source -> board_members },
  );

  has_many 'board_ranks' => 'OokOok::Resource::BoardRank', (
    is => 'ro',
    source => sub { $_[0] -> source -> board_ranks },
  );

  has_many 'board_applicants' => 'OokOok::Resource::BoardApplicant', (
    is => 'ro',
    source => sub { $_[0] -> source -> board_applicants },
  );

  # $r: project, theme, typeface
  #     These are resources that the board is trusted to manage in a way
  #     that will allow forward maintenance.
  #     For now, this is only 'project'
  method may_have_resource (Str $r) {
    $r eq 'project' ? 1 : 0;
  }

  method can_PUT {
    $self -> c -> user &&
    $self -> c -> user -> has_permission( $self -> source, 'board.admin' );
  }

  method can_GET {
    # must be a member
    $self -> c -> user && (
      $self -> c -> user -> is_admin ||
      $self -> c -> user -> board_membership( $self -> source )
    );
  }
}
