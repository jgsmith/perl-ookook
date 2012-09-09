use utf8;
package OokOok::Schema::Result::SnippetVersion;

# ABSTRACT: temporal information of a project snippet

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

prop filter => (
  data_type => 'varchar',
  is_nullable => 0,
  default_value => "HTML",
  size => 64,
);

1;
