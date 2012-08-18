use utf8;
package OokOok::Schema::Result::Library;

=head1 NAME

OokOok::Schema::Result::Library

=cut

use OokOok::EditionedResult;
use namespace::autoclean;

prop new_project_prefix => (
  data_type => 'varchar',
  is_nullable => 1,
  size => 32,
);

prop new_theme_prefix => (
  data_type => 'varchar',
  is_nullable => 1,
  size => 32,
);

has_editions;

1;
