use OokOok::Declare;

rest_controller OokOok::Controller::Snippet {

  $CLASS -> config(
    map => {
    },
    default => 'text/html',
  );

  under '/' {
    action base as 'snippet';
  }
}
