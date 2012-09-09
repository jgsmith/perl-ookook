use utf8;
package OokOok::Schema::Result::LibraryProject;

# ABSTRACT: A library as used by a project

use OokOok::VersionedResult;
use namespace::autoclean;

references library => 'OokOok::Schema::Result::Library';

1;
