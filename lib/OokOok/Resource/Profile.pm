use OokOok::Declare;

# PODNAME: OokOok::Resource::Profile

# ABSTRACT: User Profile REST resource

resource OokOok::Resource::Profile {

# ABSTRACT: Profile REST Resource

  prop uuid => (
    is => 'ro',
  );

  prop lang => (
    is => 'rw',
    isa => 'Str',
  );

  prop name => (
    is => 'rw',
    isa => 'Str',
  );

  prop url => (
    is => 'rw',
    isa => 'Str',
  );

  has_many identities => 'OokOok::Resource::OauthIdentity', (
    source => sub { $_[0] -> source -> oauth_identities }
  );
}
