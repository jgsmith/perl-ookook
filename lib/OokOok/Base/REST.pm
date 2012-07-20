package OokOok::Base::REST;

use Moose;
use namespace::autoclean;

BEGIN {
  extends 'Catalyst::Controller::REST';
}

sub do_OPTIONS {
  my($self, $c, %headers) = @_;
  $c -> response -> status(200);
  $c -> response -> headers -> header(%headers);
  $c -> response -> body('');
  $c -> response -> content_length(0);
  $c -> response -> content_type("text/plain");
  $c -> detach();
}

sub collection :Chained('base') :PathPart('') :Args(0) :ActionClass('REST') { 
}

sub collection_GET {
  my($self, $c) = @_;

  $self -> status_ok($c,
    entity => $c -> stash -> {collection} -> _GET(1)
  );
}

sub collection_POST {
  my($self, $c) = @_;

  my $manifest = $c -> stash -> {collection} -> _POST($c -> req -> data);
  $self -> status_created($c,
    location => $manifest->link,
    entity => $manifest -> _GET(1)
  );
}

sub collection_OPTIONS {
  my($self, $c) = @_;

  $self -> do_OPTIONS($c,
    Allow => [qw/GET OPTIONS POST/],
    Accept => [qw{application/json}],
  );
}

sub resource_base :Chained('base') :PathPart('') :CaptureArgs(1) {
  my($self, $c, $id) = @_;

  my $resource = $c -> stash -> {collection} -> resource($id);
  if(!$resource) {
    $self -> status_not_found($c,
      message => "Resource not found."
    );
    $c -> detach;
  }

  $c -> stash -> {resource} = $resource;
  my $rnom = $resource -> resource_name;
  $c -> stash -> {$rnom} = $resource;
}

sub resource :Chained('resource_base') :PathPart('') :Args(0) :ActionClass('REST') { }

sub resource_GET {
  my($self, $c) = @_;

  $self -> status_ok($c,
    entity => $c -> stash -> {resource} -> _GET(1)
  );
}

sub resource_PUT {
  my($self, $c) = @_;

  use Data::Dumper ();
  my $resource = $c -> stash -> {resource} -> _PUT($c -> req -> data);
  $self -> status_ok($c,
    entity => $resource -> _GET(1)
  );
}

sub resource_DELETE {
  my($self, $c) = @_;

  if($c -> stash -> {resource} -> _DELETE) {
    $self -> status_no_content($c);
  }
  else {
    $self -> status_forbidden($c,
      message => "Unable to delete resource."
    );
  }
}

sub resource_OPTIONS {
  my($self, $c) = @_;

  $self -> do_OPTIONS($c,
    Allow => [qw/GET OPTIONS PUT DELETE/],
    Accept => [qw{application/json}],
  );
}


1;
