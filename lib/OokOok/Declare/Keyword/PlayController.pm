use MooseX::Declare;

class OokOok::Declare::Keyword::PlayController
  extends CatalystX::Declare::Keyword::Controller {

  method default_superclasses { 'OokOok::Base::Player' }
}
