use OokOok::Declare;

rest_controller OokOok::Controller::ThemeLayout {

  $CLASS -> config(
    map => {
    },
    default => 'text/html',
  );

  under '/' {
    action base as "theme-layout";
  }
}
