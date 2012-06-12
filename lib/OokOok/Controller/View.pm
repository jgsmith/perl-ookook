package OokOok::Controller::View;
use Moose;
use namespace::autoclean;

BEGIN { 
  extends 'Catalyst::Controller'; 
  with 'OokOok::Role::Controller::Player';
}

__PACKAGE__ -> config(
  current_model => 'DB::Project',
);

=head1 NAME

OokOok::Controller::View - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

This controller manages the rendering of pages in projects. URLs are
of the form: 
  /v/$date/$project_id/@path (for date-based views)
  /v/$project_id/@path (for current views)
  /v/dev/$project_id/@path (for dev view)

$date =~ /^\d{4}\d{2}\d{2}\d{2}\d{2}\d{2}$/
(YYYYMMDDHHMMSS) => 14 numeric digits
$project_id =~ /^[-A-Za-z0-9_]{20}$/ => 20 base64 digits

This is for pages in the sitemap, not for components that might be
embedded within pages. Those will be under the /c/ URL space:
  /c/$date/$component_id
  /c/dev/$component_id

Theme components:
  /t/$date/...
  /t/dev/...

=head1 METHODS

=cut


=head2 index

=cut

sub base :Chained('/') :PathPart('v') :CaptureArgs(0) { }

sub play :Chained('play_base') :PathPart('') {
  my ( $self, $c ) = @_;

  my @path = @{$c -> request -> arguments};

  #my @path = @{$c -> stash -> {path}};
  unshift @path, '';

  print STDERR "Path: <", join("><", @path), ">\n";

  my $date = $c -> stash -> {date};

  # Now we know which edition of which project we want to look in
  # for the requested resource
  # We walk through the sitemap using the elements in @path

  $c -> stash -> {path} = [reverse $c -> stash -> {edition} -> page_path(@path)];

  # we expect as many entries in the stashed path as are in the @path
  if(scalar(@{$c->stash->{path}}) != scalar(@path)) {
    $c -> response->body( 'Page not found' );
    $c -> response -> status(404);
    $c -> detach;
  }

  my $page = $c -> stash -> {path} -> [0];

  if(!$page) {
    $c -> response->body( 'Page not found' );
    $c -> response -> status(404);
    $c -> detach;
  }

  $c -> stash -> {page} = $page;

  $c -> stash -> {rendering} = $page -> render($c);

  $c -> stash -> {template} = 'view/play.tt2';
};

=head1 AUTHOR

James Smith,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
