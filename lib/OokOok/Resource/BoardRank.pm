package OokOok::Resource::BoardRank;

use OokOok::Resource;
use namespace::autoclean;

has '+source' => (
  isa => 'OokOok::Model::DB::BoardRank'
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

sub can_GET { $_[0] -> board -> can_GET }
sub can_PUT { $_[0] -> board -> can_PUT }

1;
