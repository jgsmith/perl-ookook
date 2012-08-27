use CatalystX::Declare;

controller OokOok::Controller::Library
   extends OokOok::Base::REST
{

  $CLASS -> config(
    map => {
    },
    default => 'text/html',
  );

  under '/' {
    action base as 'library';
  }
}
