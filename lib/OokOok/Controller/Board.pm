use OokOok::Declare;

# PODNAME: OokOok::Controller::Board

# ABSTRACT: REST controller for boards

rest_controller OokOok::Controller::Board
{

  $CLASS -> config(
    map => {
    },
    default => 'text/html',
  );

}
