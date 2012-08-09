package OokOok::Resource::BoardApplicant;
use OokOok::Resource;
use namespace::autoclean;

has '+source' => (
  isa => 'OokOok::Model::DB::BoardApplicant'
);

prop id => (
  type => 'Str',
  is => 'ro',
  source => sub { $_[0] -> source -> uuid },
);

prop status => (
  type => 'Str',
);

belongs_to board => 'OokOok::Resource::Board', (
  is => 'ro',
  required => 1,
);

belongs_to user => 'OokOok::Resource::User', (
  is => 'ro',
  required => 1,
);

1;