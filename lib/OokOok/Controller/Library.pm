use OokOok::Declare;

rest_controller OokOok::Controller::Library {

  $CLASS -> config(
    map => {
    },
    default => 'text/html',
  );

  under '/' {
    action base as 'library';
  }
}
