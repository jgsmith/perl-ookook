package OokOok::Controller::Admin::OAuth;
use Moose;
use namespace::autoclean;
use Catalyst::Authentication::Store::DBIx::Class;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

OokOok::Controller::Admin::OAuth - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path('') :Args(1) {
  my( $self, $c, $provider ) = @_;

  if($provider eq 'logout') {
    $c -> logout;
    $c -> res -> redirect($c -> uri_for('/'));
  }

  if($c -> authenticate($provider)) {
    my $redirect = delete $c -> session -> {redirect};
    $redirect = $c -> uri_for('/admin') unless $redirect;
    $c -> res -> redirect( $redirect );
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
