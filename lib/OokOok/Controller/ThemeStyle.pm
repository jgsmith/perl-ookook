use OokOok::Declare;

rest_controller OokOok::Controller::ThemeStyle {

  $CLASS -> config(
    map => {
    },
    default => 'text/html',
  );

  under '/' {
    action base as "theme-style";
  }
}
