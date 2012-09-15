use CatalystX::Declare;

# PODNAME: OokOok::Declare::Base::Admin

# ABSTRACT: Baseclass for administrative interface controllers

controller OokOok::Declare::Base::Admin {

  use MooseX::Types::Moose qw(Str);

  final action begin (@rest) is private {
    return if $ctx -> action -> class eq "OokOok::Controller::Admin::OAuth";
    if(!$ctx -> user) {
      # redirect to admin top-level page
      $ctx -> session -> {redirect} = $ctx -> request -> uri;
      $ctx -> session -> {allow_GET_for_oauth} = 1;
      $ctx -> response -> redirect($ctx -> uri_for("/admin/oauth/twitter"));
      $ctx -> detach;
    }

    $ctx -> stash -> {development} = 1;
  }

  final action end (@args) is private isa RenderView;

  method doMethod (
      Object  $ctx, 
      Str     $method, 
      Object  $resource, 
      HashRef $params
  ) {
    my $thing = eval {
      $resource -> $method($params);
    };

    my $e = $@;

    $ctx -> stash -> {form_data} = $ctx -> request -> params;
    if($e) {
      if(blessed($e)) {
        if($e -> isa('OokOok::Exception::PUT')) {
          $ctx -> stash -> {error_msg} = $e -> message;
          $ctx -> stash -> {missing} = $e -> missing;
          $ctx -> stash -> {invalid} = $e -> invalid;
          return;
        }
        if($e -> isa('OokOok::Exception')) {
          $ctx -> stash -> {error_msg} = $e -> message;
          return;
        }
      }
      else {
        die $e; # rethrow
      }
    }
    return $thing;
  }

  method PUT (
      Object        $ctx,
      Str|Object   :$resource, 
      HashRef|Bool :$params = 0, 
      Bool         :$redirect = 1
  ) {
    if(!$params) {
      $params = $ctx -> request -> params;
    }
    if(is_Str($resource)) { # key in stash
      $resource = $ctx -> stash -> {$resource};
    }
    my $res = $self -> doMethod($ctx, "_PUT", $resource, $params);
    if($redirect && $res) {
      if(!$params -> {_continue}) {
        my $url = $ctx -> request -> uri;
        my $path = $url -> path;
        $path =~ s{[-A-Za-z0-9_]{20}/edit}{};
        $url -> path($path);
        $ctx -> response -> redirect( $path );
        $ctx -> detach;
      }
    }

    return $res;
  }

  method POST (
      Object            $ctx, 
      Object|ClassName :$collection, 
      HashRef|Bool     :$params = 0, 
      Bool             :$redirect = 1
  ) { 
    if(is_Str($collection)) {
      $collection = $collection -> new( c => $ctx );
    }
    if(!$params) {
      $params = $ctx -> request -> params;
    }
    my $res = $self -> doMethod($ctx, "_POST", $collection, $params);
    if($redirect && $res) {
      my $url = $ctx -> request -> uri;
      my $path = $url -> path;
      $path =~ s{new$}{};
      if(!$params -> {_continue}) {
        $url -> path($path);
      }
      else {
        $url -> path($path . $res -> id . '/edit');
      }
      $ctx -> response -> redirect( $url );
      $ctx -> detach;
    }
    return $res;
  }

  method DELETE (
      Object      $ctx, 
      Object|Str :$resource
  ) { 
    if(is_Str($resource)) {
      $resource = $ctx -> stash -> {$resource};
    }
    $self -> doMethod($ctx, "_DELETE", $resource);
  }
}
