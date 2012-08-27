use CatalystX::Declare;

controller OokOok::Controller::ThemeStyle
   extends OokOok::Base::REST
{

  $CLASS -> config(
    map => {
    },
    default => 'text/html',
  );

  under '/' {
    action base as "theme-style";
  }
}
