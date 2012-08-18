use utf8;
package OokOok::Schema::Result::SnippetVersion;

=head1 NAME

OokOok::Schema::Result::SnippetVersion

=cut

use OokOok::ResultVersion;
use namespace::autoclean;

is_publishable;

prop name => (
  data_type => 'varchar',
  is_nullable => 0,
  default_value => 'unnamed',
  size => 255,
);

prop content => (
  data_type => 'text',
  is_nullable => 1,
);

1;
