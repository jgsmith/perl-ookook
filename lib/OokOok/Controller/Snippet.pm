use OokOok::Declare;

# PODNAME: OokOok::Controller::Snippet

# ABSTRACT: REST Controller for Project Snippets

rest_controller OokOok::Controller::Snippet {

  __PACKAGE__ -> config(
    map => {
    },
    default => 'text/html',
  );

}
