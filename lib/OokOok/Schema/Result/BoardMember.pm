use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::BoardMember

# ABSTRACT: information about a user's membership on a board

Table OokOok::Schema::Result::BoardMember {

  prop rank => (
    data_type => 'integer',
    default_value => 0,
    is_nullable => 0,
  );

  owns_many board_member_applicants => 'OokOok::Schema::Result::BoardMemberApplicant';

  method board_rank {
    $self -> board -> board_ranks -> find({ position => $self -> rank });
  }

}
