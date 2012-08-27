use CatalystX::Declare;

controller OokOok::Controller::ThemeLayout
   extends OokOok::Base::REST
{
  $CLASS -> config(
    map => {
    },
    default => 'text/html',
  );

  under '/' {
    action base as "theme-layout";
  }
}
