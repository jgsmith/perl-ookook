use OokOok::Declare;

# PODNAME: OokOok::Controller::Library

# ABSTRACT: Controller for the Library REST interface

rest_controller OokOok::Controller::Library {
  $CLASS -> config(
    default => 'text/html'
  );
}
