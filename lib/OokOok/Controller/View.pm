package OokOok::Controller::View;
use Moose;
use namespace::autoclean;

use OokOok::Template::Context;

BEGIN { 
  extends 'OokOok::Base::Player';
}

__PACKAGE__ -> config(
  map => {
    'text/html' => [ 'View', 'HTML' ],
  },
  default => 'text/html',
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

sub base :Chained('/') :PathPart('v') :CaptureArgs(0) { 
  my($self, $c) = @_;

  $c -> stash -> {collection} = OokOok::Collection::Project -> new(
    c => $c,
  );
}

sub play :Chained('play_base') :PathPart('') :ActionClass('REST') {
  my ( $self, $c ) = @_;

  my @path = @{$c -> request -> arguments};

  my $date = $c -> stash -> {date};

  # now we walk the sitemap to find the right page
  my $page = $c -> stash -> {project} -> page;
  my($slug, $last_page);

  $last_page = $page;
  while($page && @path) {
    $slug = shift @path;
    $last_page = $page;
    $page = $page -> get_child_page($slug);
    if(!$page) { unshift @path, $slug; }
  }
  $page = $last_page;

  # we expect as many entries in the stashed path as are in the @path
  # for now, we shouldn't have anything left in @path -- we don't have
  # pages yet that can react to extra path info
  if(!$page || @path) {
    $c -> response->body( 'Page not found' );
    $c -> response -> status(404);
    $c -> detach;
  }

  $c -> stash -> {page} = $page;
}

sub play_GET {
  my($self, $c) = @_;

  my $context = OokOok::Template::Context -> new(
    c => $c
  );

  my $page = $c -> stash -> {page};
  $context -> set_resource(page => $page);
  $context -> set_resource(project => $c -> stash -> {project});

  $c -> stash -> {rendering} = $page -> render($context);
  my $project_uuid = $page -> project -> source -> uuid;
  $c -> stash -> {stylesheets} = [ map {
    $c -> uri_for( "/s/$project_uuid/style/$_" )
  } $page -> stylesheets ];

  $c -> stash -> {template} = 'view/play.tt2';
  $c -> forward( $c -> view('HTML') );
}

=head1 AUTHOR

James Smith,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
