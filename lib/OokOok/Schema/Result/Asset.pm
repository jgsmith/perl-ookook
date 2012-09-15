use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::Asset

# ABSTRACT: Project Asset database row

versioned_table OokOok::Schema::Result::Asset {

  owns_many attachments => 'OokOok::Schema::Result::Attachment';

}
