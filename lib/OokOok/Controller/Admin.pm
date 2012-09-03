use CatalystX::Declare;

controller OokOok::Controller::Admin 
   extends OokOok::Base::Admin {

  final action index as '' {
    $ctx -> stash -> {projects} = [
      OokOok::Collection::Project -> new(c => $ctx) -> resources
    ];
    $ctx -> stash -> {boards} = [
      OokOok::Collection::Board -> new(c => $ctx) -> resources
    ];
    if($ctx -> user -> is_admin) {
      $ctx -> stash -> {themes} = [
        OokOok::Collection::Theme -> new(c => $ctx) -> resources
      ];
    }
    $ctx -> stash -> {template} = "/admin/top/dashboard";
  }

  final action end (@rest) is private isa RenderView;

}

1;
