use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::Asset

# ABSTRACT: Project Asset database row

versioned_table OokOok::Schema::Result::Asset {

  owns_many attachments => 'OokOok::Schema::Result::Attachment';

}

=head1 DESCRIPTION

Assets are designed to be used in conjunction with themes. A theme
has assets as well, but will defer to project-owned assets when
possible, allowing a project to override the assets provided by a
theme.

Assets may be used for elements of the project that aren't designed
for study. Assets do not have extensive metadata associated with them, so
they are not designed to handle objects that should be in a proper
digital library archive.

=cut
