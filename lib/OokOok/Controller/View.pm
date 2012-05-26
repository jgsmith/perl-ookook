package OokOok::Controller::View;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

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

sub default :Chained('/') :PathPart('v') {
  my ( $self, $c ) = @_;

  my @path = @{$c -> request -> arguments};
  my $date = DateTime -> now;

  if(!@path) {
    $c->response->body( 'Page not found' );
    $c->response->status(404);
    $c->detach();
  }
  elsif($path[0] eq 'dev') {
    # development version
    shift @path;
    my $uuid = shift @path;
    my $project = $c -> model('DB::Project') -> find({ uuid => $uuid });
    if(!$project) {
      # 404 - not found
      $c->response->body( 'Page not found' );
      $c->response->status(404);
      $c->detach();
    }
    $c -> stash(project => $project);
    $c -> stash(edition => $project -> current_edition);
    $date = undef;
  }
  elsif($path[0] =~ /^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$/) {
    shift @path;
    $date = DateTime -> new({
      year => $1,
      month => $2,
      day => $3,
      hour => $4,
      minute => $5,
      second => $6
    });
    my $uuid = shift @path;
    my $project = $c -> model('DB::Project') -> find({ uuid => $uuid });
    if(!$project) {
      # 404 - not found
      $c->response->body( 'Page not found' );
      $c->response->status(404);
      $c->detach();
    }
    $c -> stash(project => $project);
    $c -> stash(edition => $project -> edition_for_date($date));
  }
  else {
    my $uuid = shift @path;
    my $project = $c -> model('DB::Project') -> find({ uuid => $uuid });
    if(!$project) {
      # 404 - not found
      $c->response->body( 'Page not found' );
      $c->response->status(404);
      $c->detach();
    }
    $c -> stash(project => $project);
    $c -> stash(edition => $project -> edition_for_date($date));
  }

  # put the top-level page on the stack
  unshift @path, '';

  $c -> stash(date => $date);

  # Now we know which edition of which project we want to look in
  # for the requested resource
  # We walk through the sitemap using the elements in @path

  my $sitemap = $c -> stash -> {edition} -> sitemap;

  my $page_uuid;
  while(@path && !$page_uuid && $sitemap) {
    my $slug = shift @path;
    if($sitemap->{$slug}) {
      if(!@path) {
        $page_uuid = $sitemap->{$slug}->{visual};
      }
      else {
        $sitemap = $sitemap->{$slug}->{children};
      }
    }
  }

  if(!$page_uuid) {
    $c -> response->body( 'Page not found' );
    $c -> response -> status(404);
    $c -> detach;
  }

  my $page = $c -> stash -> {project} -> page_for_date($page_uuid, $c -> stash -> {date});

  if(!$page) {
    $c -> response->body( 'Page not found' );
    $c -> response -> status(404);
    $c -> detach;
  }

  $c -> stash -> {page} = $page;
}

=head1 AUTHOR

James Smith,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
