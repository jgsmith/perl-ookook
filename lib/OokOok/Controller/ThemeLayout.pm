use OokOok::Declare;

# PODNAME: OokOok::Controller::ThemeLayout

# ABSTRACT: Controller for Theme Layout REST interface

rest_controller OokOok::Controller::ThemeLayout {

  __PACKAGE__ -> config(
    map => {
    },
    default => 'text/html',
  );

}
