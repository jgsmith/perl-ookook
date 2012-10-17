use CatalystX::Declare;

# PODNAME: OokOok::Declare::Base::Player

# ABSTRACT: Base class for player-style controllers

controller OokOok::Declare::Base::Player
   extends Catalyst::Controller::REST
{

  under base {
    action play_base ($uuid) as '' {
      my $resource = $ctx -> stash -> {collection} -> resource($uuid);

      if(!$resource) {
        $ctx -> detach(qw/Controller::Root default/);
      }

      $ctx -> stash -> {resource} = $resource;
      $ctx -> stash -> {$resource -> resource_name} = $resource;
    }
  }

  #final action end (@args) isa RenderView;
}
