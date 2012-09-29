use OokOok::Declare;

# PODNAME: OokOok::Resource::OauthIdentity

# ABSTRACT: OAuth Identity REST resource

resource OokOok::Resource::OauthIdentity {

  prop service => (
    is => 'ro',
    source => sub {
      my($self) = @_;
      my $id = $self -> source -> oauth_service_id;
      for my $service (keys %{$self -> c -> config -> {'OokOok::Plugin::Authentication'}->{providers}}) {
        if($self -> c -> config -> {'OokOok::Plugin::Authentication'}->{providers}->{$service}->{id} == $id) {
          return $service;
        }
      }
    },
  );

  method link {
    my $service = $self -> service;
    $self -> c -> uri_for('/oauth/' . $service) -> as_string;
  }

  method can_PUT { 0 }
}
