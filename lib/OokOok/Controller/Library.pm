use OokOok::Declare;

# PODNAME: OokOok::Controller::Library

# ABSTRACT: Controller for the Library REST interface

rest_controller OokOok::Controller::Library {
  __PACKAGE__ -> config(
    default => 'text/html'
  );
}
