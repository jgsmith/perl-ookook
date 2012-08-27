use CatalystX::Declare;

controller OokOok::Controller::Board
   extends OokOok::Base::REST
{

  $CLASS -> config(
    map => {
    },
    default => 'text/html',
  );

  under '/' {
    action base as 'board';
  }

}
