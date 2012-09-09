use OokOok::Declare;

# PODNAME: OokOok::Controller::ThemeLayout

# ABSTRACT: Controller for Theme Layout REST interface

rest_controller OokOok::Controller::ThemeLayout {

  $CLASS -> config(
    map => {
    },
    default => 'text/html',
  );

}
