use utf8;
package OokOok::Schema::Result::LibraryTheme;

# ABSTRACT: a library as used by a theme

use OokOok::VersionedResult;
use namespace::autoclean;

references library => 'OokOok::Schema::Result::Library';

1;
