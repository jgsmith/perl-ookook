package OokOok::Controller::Profile;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST'; }

__PACKAGE__ -> config(
  map => {
  },
  default => 'text/html',
);

=head1 NAME

OokOok::Controller::Profile - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) :ActionClass('REST') { }

sub index_GET {
  my ( $self, $c ) = @_;

  if($c -> user) {
    my $profile = {
      name => $c -> user -> name,
      url  => $c -> user -> url,
      lang => $c -> user -> lang,
      services => [ ]
    };

    for my $provider (keys %{$c -> config -> {'OokOok::Plugin::Authentication'}->{providers}}) {
      my $pinfo = $c -> config -> {'OokOok::Plugin::Authentication'} -> {providers} -> {$provider};
      my $oauth_identity = $c -> user -> oauth_identities -> find({ oauth_service_id => $pinfo -> {id} });
      push @{$profile->{services}}, {
        name => $pinfo -> {title},
        url => $c -> uri_for("/oauth/" . $provider) -> as_string,
        connected => defined($oauth_identity),
      };
    }

    $self -> status_ok($c,
      entity => $profile
    );
  }
  else {
    $self -> status_forbidden($c,
      message => 'Profile unavailable if not authenticated.'
    );
  }
}

=head1 AUTHOR

James Smith,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
