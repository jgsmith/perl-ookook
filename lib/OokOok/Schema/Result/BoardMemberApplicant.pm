use utf8;
package OokOok::Schema::Result::BoardMemberApplicant;

# ABSTRACT: A board member's comment and vote about a board applicant

use OokOok::Result;
use namespace::autoclean;

prop vote => (
  data_type => 'integer',
  is_nullable => 1,
);

prop comments => (
  data_type => 'text',
  is_nullable => 1,
);

1;
