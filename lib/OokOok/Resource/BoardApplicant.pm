use OokOok::Declare;

# PODNAME: OokOok::Resource::BoardApplicant

# ABSTRACT: Board Applicant REST resource

resource OokOok::Resource::BoardApplicant {

  prop id => (
    type => 'Str',
    is => 'ro',
    source => sub { $_[0] -> source -> uuid },
  );

  prop status => (
    type => 'Str',
    permission => 'board.member.add',
  );

  belongs_to board => 'OokOok::Resource::Board', (
    is => 'ro',
    required => 1,
  );

  belongs_to user => 'OokOok::Resource::User', (
    is => 'ro',
    required => 1,
  );

}
