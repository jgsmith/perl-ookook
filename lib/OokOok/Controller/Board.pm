use OokOok::Declare;

rest_controller OokOok::Controller::Board
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
