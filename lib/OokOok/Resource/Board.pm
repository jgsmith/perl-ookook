use OokOok::Declare;

# PODNAME: OokOok::Resource::Board

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

  method can_PUT {
    return 1;
  }

  method can_GET {
    return 1;
  }
}
