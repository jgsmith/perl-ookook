use OokOok::Declare;

# PODNAME: OokOok::Resource::Asset

# ABSTRACT: Project Asset REST Resource

resource OokOok::Resource::Asset {

  prop id => (
    is => 'ro',
    source => sub { $_[0] -> source -> uuid },
  );

  prop media_format => (
    is => 'rw',
    source => sub { $_[0] -> source_version -> media_format },
  );

  prop name => (
    is => 'rw',
    source => sub { $_[0] -> source_version -> name },
  );

  after EXPORT ($bag) {
    # add asset content
  }

}

=head1 DESCRIPTION

Assets are used in the theme and layout of a project site. Assets are not
considered objects of study.

=cut
