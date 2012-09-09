use utf8;
package OokOok::Schema::Result::BoardApplicant;

# ABSTRACT: an applicant for membership on a board

use OokOok::Result;
use namespace::autoclean;

with_uuid;

my @status = ['preliminary', 'vote in progress', 'denied', 'accepted'];
my %status = map { $status[$_] => $_ } 0..$#status;

prop status => (
  data_type => 'integer',
  default_value => 0,
  is_nullable => 0,
  inflate => sub { 
    my($status,$self) = @_;
    $status = $status[$status] || 'unknown';
    if($status eq 'vote in progress' && $self -> vote_deadline &&
         $self -> vote_deadline < DateTime->now) {
      $status = 'vote concluded';
    }
    $status;
  },
  deflate => sub { 
    my($status, $self) = @_;
    if($status eq 'vote concluded') {
      $status = 'vote in progress';
    }
    $status{$status} || -1;
  },
);

prop vote_deadline => (
  data_type => 'datetime',
  is_nullable => 1,
);

prop application => (
  data_type => 'text',
  is_nullable => 1,
);

owns_many board_member_applicants => 'OokOok::Schema::Result::BoardMemberApplicant';

1;
