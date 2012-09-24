use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::BoardMember

# ABSTRACT: information about a user's membership on a board

Table OokOok::Schema::Result::BoardMember {

  method rank { $self -> board_rank -> position }

  owns_many board_member_applicants => 'OokOok::Schema::Result::BoardMemberApplicant';

}
