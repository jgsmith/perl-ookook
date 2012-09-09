use utf8;
package OokOok::Schema::Result::Asset;

# ABSTRACT: Project Asset database row

use OokOok::VersionedResult;
use namespace::autoclean;

owns_many attachments => 'OokOok::Schema::Result::Attachment';

1;
