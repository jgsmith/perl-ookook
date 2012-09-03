use utf8;
package OokOok::Schema::Result::Asset;

=head1 NAME

OokOok::Schema::Result::Asset

=cut

use OokOok::VersionedResult;
use namespace::autoclean;

owns_many attachments => 'OokOok::Schema::Result::Attachment';

1;
