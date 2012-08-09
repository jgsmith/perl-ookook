package OokOok::Base::Admin;

use Moose;
BEGIN {
  extends 'Catalyst::Controller';
}

use namespace::autoclean;

sub begin : Private {
  my($self, $c) = @_;

  if(!$c -> user) {
    # redirect to admin top-level page
    $c -> session -> {redirect} = $c -> request -> uri;
    $c -> response -> redirect($c -> uri_for("/admin/oauth/twitter"));
    $c -> detach;
  }

  $c -> stash -> {development} = 1;
}

sub end : ActionClass('RenderView') { }

sub doMethod :Private {
  my($self, $method, $c, $resource, $params) = @_;

  my $thing = eval {
    $resource -> $method($params);
  };

  my $e = $@;

  if($e) {
    if(blessed($e) && $e -> isa('OokOok::Exception::PUT')) {
      $c -> stash -> {form_data} = $c -> request -> params;
      $c -> stash -> {error_msg} = $e -> message;
      $c -> stash -> {missing} = $e -> missing;
      $c -> stash -> {invalid} = $e -> invalid;
      return;
    }
    else {
      die $e; # rethrow
    }
  }
  return $thing;
}

sub PUT :Private { shift -> doMethod("_PUT", @_) }
sub POST :Private { shift -> doMethod("_POST", @_) }

1;
