package OokOok::Base::Player;

use Moose;
BEGIN {
  extends 'Catalyst::Controller::REST';
}
use namespace::autoclean;

sub play_base :Chained('base') :PathPart('') :CaptureArgs(1) {
  my($self, $c, $uuid) = @_;

  my $resource = $c -> stash -> {collection} -> resource($uuid);

  if(!$resource) {
    $c -> detach(qw/Controller::Root default/);
  }

  $c -> stash -> {resource} = $resource;
  $c -> stash -> {$resource -> resource_name} = $resource;
}

sub end : ActionClass('RenderView') {}

1;
