use utf8;
package OokOok::Schema::Result::LibraryProjectVersion;

# ABSTRACT: temporal data about how a project uses a library

use OokOok::ResultVersion;
use namespace::autoclean;

prop library_date => (
  data_type => 'datetime',
  is_nullable => 0,
);

prop prefix => (
  data_type => 'varchar',
  is_nullable => 1,
  size => 32,
);

1;
