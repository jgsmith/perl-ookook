package OokOok::Controller::Admin;

use Moose;
use namespace::autoclean;

BEGIN {
  extends 'Catalyst::Controller';
}

sub index :Path :Args(0) {
  my($self, $c) = @_;

  if($c -> user) {
    $c -> response -> redirect($c -> uri_for("/admin/project"));
  }
  else {
    $c -> stash -> {template} = 'admin/login';
  }
}

sub end : ActionClass('RenderView') { }

1;
