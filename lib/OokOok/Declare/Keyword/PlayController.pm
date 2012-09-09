use MooseX::Declare;

# PODNAME: OokOok::Declare::Keyword::PlayController

# ABSTRACT: Provides the play_controller keyword

class OokOok::Declare::Keyword::PlayController
  extends CatalystX::Declare::Keyword::Controller {

  method default_superclasses { 'OokOok::Base::Player' }
}
