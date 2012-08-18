use utf8;
package OokOok::Schema::Result::LibraryTheme;

=head1 NAME

OokOok::Schema::Result::LibraryTheme

=cut

use OokOok::VersionedResult;
use namespace::autoclean;

references library => 'OokOok::Schema::Result::Library';

1;
