use CatalystX::Declare;

controller OokOok::Controller::Snippet
   extends OokOok::Base::REST
{

  $CLASS -> config(
    map => {
    },
    default => 'text/html',
  );

  under '/' {
    action base as 'snippet';
  }
}
