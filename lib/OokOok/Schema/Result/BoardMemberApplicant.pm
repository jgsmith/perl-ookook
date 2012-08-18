use utf8;
package OokOok::Schema::Result::BoardMemberApplicant;

=head1 NAME

OokOok::Schema::Result::BoardMemberApplicant

=cut

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
