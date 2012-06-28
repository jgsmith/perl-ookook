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

    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 dashboard

Show the user an overview of their account and activity.

=cut

sub dashboard :Path('dashboard') :Args(0) {
    my($self, $c) = @_;

    $c -> stash -> {projects} = [$c -> model("DB::Project") -> all];
    $c -> stash -> {themes} = [$c -> model("DB::Theme") -> all];
    $c -> stash -> {libraries} = [$c -> model("DB::Library") -> all];
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
