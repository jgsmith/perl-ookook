use utf8;
package OokOok::Schema::Result::ThemeSnippetVersion;

=head1 NAME

OokOok::Schema::Result::ThemeSnippetVersion

=cut

use OokOok::ResultVersion;
use namespace::autoclean;

is_publishable;

prop name => (
  data_type => 'varchar',
  default_value => '',
  is_nullable => 0,
  size => 255,
);

prop content => (
  data_type => 'text',
  is_nullable => 0,
  default_value => '',
);

prop filter => (
  data_type => 'varchar',
  is_nullable => 0,
  default_value => "HTML",
  size => 64,
);

1;
