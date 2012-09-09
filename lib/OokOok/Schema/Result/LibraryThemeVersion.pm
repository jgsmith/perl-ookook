use utf8;
package OokOok::Schema::Result::LibraryThemeVersion;

# ABSTRACT: temporal information about how a theme uses a library

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

before insert => sub {
  my($self) = @_;

  if(!$self -> library_date) {
    $self -> library_date(DateTime->now());
  };
};

1;
