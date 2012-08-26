use CatalystX::Declare;

controller OokOok::Controller::Admin {

  final action index as '' {
    if($ctx -> user) {
      $ctx -> response -> redirect($ctx -> uri_for("/admin/project"));
    }
    else {
      $ctx -> stash -> {template} = 'admin/login';
    }
  }

  final action end (@rest) is private isa RenderView;

}

1;
