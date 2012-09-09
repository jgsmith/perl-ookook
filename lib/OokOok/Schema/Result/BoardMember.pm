use utf8;
package OokOok::Schema::Result::BoardMember;

# ABSTRACT: information about a user's membership on a board

use OokOok::Result;
use namespace::autoclean;

prop rank => (
  data_type => 'integer',
  default_value => 0,
  is_nullable => 0,
);

owns_many board_member_applicants => 'OokOok::Schema::Result::BoardMemberApplicant';

sub board_rank {
  $_[0] -> board -> board_ranks -> find({ position => $_[0] -> rank });
}


1;
