use OokOok::Declare;

# PODNAME: OokOok::Resource::BoardRank

# ABSTRACT: Board Rank REST resource

resource OokOok::Resource::BoardRank {

  prop id => (
    is => 'ro',
    source => sub { $_[0] -> source -> board -> uuid . "-r" . $_[0] -> source -> position }
  );

  prop name => (
    required => 1,
    type => 'Str',
  );

  prop position => (
    required => 1,
    type => 'Int',
  );

  belongs_to board => 'OokOok::Resource::Board', (
    is => 'ro',
    required => 1,
  );

  has_many board_members => 'OokOok::Resource::BoardMember', (
    is => 'ro',
    source => sub { $_[0] -> source -> board_members },
  );

  method can_GET { $self -> board -> can_GET }
  method can_PUT { $self -> board -> can_PUT }
}
