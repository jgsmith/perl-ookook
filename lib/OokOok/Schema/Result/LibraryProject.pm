use utf8;
package OokOok::Schema::Result::LibraryProject;

=head1 NAME

OokOok::Schema::Result::LibraryProject

=cut

use OokOok::VersionedResult;
use namespace::autoclean;

references library => 'OokOok::Schema::Result::Library';

1;
