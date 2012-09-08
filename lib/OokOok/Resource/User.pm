use OokOok::Declare;

resource OokOok::Resource::User {

  #has '+source' => (
  #  isa => 'OokOok::Model::DB::User',
  #);

  prop id => (
    source => sub { $_[0] -> source -> uuid },
    is => 'ro',
  );

  prop lang => (
    is => 'rw',
    isa => 'Str',
  );

  prop name => (
    is => 'rw',
    isa => 'Str',
    required => 1,
  );

  prop url => (
    is => 'rw',
    isa => 'Str',
  );

  prop timezone => (
    is => 'rw',
    isa => 'Str',
  );

  prop description => (
    is => 'rw',
    isa => 'Str',
  );

  has_many board_members => 'OokOok::Resource::BoardMember', (
    is => 'ro',
    source => sub { $_[0] -> source -> board_members },
  );

  has_many boards => 'OokOok::Resource::Board', (
    is => 'ro',
    source => sub { 
      my($self) = @_;
      $self -> c -> model('DB::Board') -> search({
        'board_member.user_id' => $self -> source -> id,
      }, {
        join => [qw/board_member/],
      }) -> all
    },
  );
}
