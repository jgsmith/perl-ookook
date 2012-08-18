use utf8;
package OokOok::Schema::Result::BoardMember;

=head1 NAME

OokOok::Schema::Result::BoardMember

=cut

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
