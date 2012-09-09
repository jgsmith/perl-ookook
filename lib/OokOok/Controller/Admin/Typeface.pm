use OokOok::Declare;

# PODNAME: OokOok::Controller::Admin::Typeface

# ABSTRACT: Controller to administer Typeface resources

admin_controller OokOok::Controller::Admin::Typeface {

  under '/' {
    action base as 'admin/typeface';
  }

  under base {

    action typeface_base (Str $uuid) as '' {
      my $resource = OokOok::Collection::Typeface->new(c => $ctx)
                                                 ->resource($uuid);
      if(!$resource) {
        $ctx -> detach(qw/Controller::Root default/);
      }
      $ctx -> stash -> {typeface} = $resource;
    }

  }

  under base {
    final action index as '' {
      $ctx -> stash -> {typefaces} = [
        OokOok::Collection::Typeface -> new(c => $ctx) -> resources
      ];
      $ctx -> stash -> {template} = "/admin/top/typefaces";
    }
  }

}
