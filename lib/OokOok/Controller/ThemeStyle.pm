use OokOok::Declare;

# PODNAME: OokOok::Controller::ThemeStyle

# ABSTRACT: Controller for theme style REST interface

rest_controller OokOok::Controller::ThemeStyle {

  $CLASS -> config(
    map => {
    },
    default => 'text/html',
  );

}
