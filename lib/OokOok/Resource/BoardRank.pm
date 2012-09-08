use OokOok::Declare;

resource OokOok::Resource::BoardRank {

  #has '+source' => (
  #  isa => 'OokOok::Model::DB::BoardRank'
  #);

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
    source => sub {
      my($self) = @_;
      $self -> source -> board -> board_members -> search({
        rank => $self -> source -> position
      })
    },
  );

  method can_GET { $self -> board -> can_GET }
  method can_PUT { $self -> board -> can_PUT }
}
