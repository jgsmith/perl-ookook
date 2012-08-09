package OokOok::Resource::OauthIdentity;

use OokOok::Resource;

use namespace::autoclean;

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

sub link {
  my($self) = @_;

  my $service = $self -> service;
  $self -> c -> uri_for('/oauth/' . $service) -> as_string;
}

sub can_PUT { 0 }

1;
