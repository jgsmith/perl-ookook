package OokOok::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

OokOok::Controller::Root - Root Controller for OokOok

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c -> stash(template => 'index.tt2');
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;

#    print STDERR "default path: [", $c -> req -> path, "]\n";
#    if($c -> stash -> {development}) {
#      $c -> req -> path = "/dev" . $c -> req -> path;
#    }
#    elsif($c -> stash -> {date}) {
#      $c -> req -> path = "/" . $c -> stash -> {date} -> strftime('%Y%m%d%H%M%S') . $c -> req -> path;
#    }
#    else {
#      my $path = $c -> req -> path;
#      print STDERR "path: [$path]\n";
#      if($path =~ s{^dev/}{/}) {
#        print STDERR "  development...\n";
#        $c -> stash -> {development} = 1;
#        $c -> detach($path);
#        #$c -> req -> path($path);
#        #$c -> dispatcher -> prepare_action($c);
#        #return $c -> dispatcher -> dispatch($c);
#      }
#      elsif($path =~ s{^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/}{/}) {
#        $c -> stash -> {date} = DateTime -> new({
#          year => $1,
#          month => $2,
#          day => $3,
#          hour => $4,
#          minute => $5,
#          second => $6
#        });
#        print STDERR "  date... ", $c -> stash -> {date}, "\n";
#        $c -> detach($path);
#        #$c -> dispatcher -> prepare_action($c);
#        #return $c -> dispatcher -> dispatch($c);
#      }
#    }
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 dashboard

Show the user an overview of their account and activity.

=cut

sub dashboard :Path('dashboard') :Args(0) {
    my($self, $c) = @_;

}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

James Smith,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
