use utf8;
package OokOok::Schema::Result::Email;

=head1 NAME

OokOok::Schema::Result::Email

=cut

use OokOok::Result;
use namespace::autoclean;

prop verified => (
  data_type => 'boolean',
  default_value => 0,
  is_nullable => 0,
);

prop email => (
  data_type => 'varchar',
  is_nullable => 0,
  size => 255,
  unique => 1,
);

1;
