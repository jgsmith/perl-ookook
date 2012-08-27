use CatalystX::Declare;

controller OokOok::Base::Admin {

  final action begin is private {
    if(!$ctx -> user) {
      # redirect to admin top-level page
      $ctx -> session -> {redirect} = $ctx -> request -> uri;
      $ctx -> response -> redirect($ctx -> uri_for("/admin/oauth/twitter"));
      $ctx -> detach;
    }

    $ctx -> stash -> {development} = 1;
  }

  final action end (@args) isa RenderView;

  final action doMethod ($method, $resource, $params) is private {
    my $thing = eval {
      $resource -> $method($params);
    };

    my $e = $@;

    if($e) {
      if(blessed($e)) {
        if($e -> isa('OokOok::Exception::PUT')) {
          $ctx -> stash -> {form_data} = $ctx -> request -> params;
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

  final action PUT (@args) is private { $self -> doMethod($ctx, "_PUT", @args) }
  final action POST (@args) is private { $self -> doMethod($ctx, "_POST", @args) }
  final action DELETE (@args) is private { $self -> doMethod($ctx, "_DELETE", @args) }
}
