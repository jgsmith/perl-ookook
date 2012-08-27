use CatalystX::Declare;

controller OokOok::Controller::Project
   extends OokOok::Base::REST
{

  use OokOok::Collection::Project;
  use OokOok::Collection::Edition;
  use OokOok::Collection::Page;
  use OokOok::Collection::Snippet;

  use JSON;

  $CLASS -> config(
    map => {
    },
    default => 'text/html',
  );

  #
  # base establishes the root slug for the project management
  # routes
  #

  under '/' {
    action base as 'project';
  }

  ###
  ### Project-specific information/resources
  ###

  under resource_base {
    final action pages as 'page' isa REST {
      $ctx -> stash -> {collection} = 
        OokOok::Collection::Page -> new(c => $ctx);
    }

    final action snippets as 'snippet' isa REST {
      $ctx -> stash -> {collection} = 
        OokOok::Collection::Snippet -> new(c => $ctx);
    }

    final action editions as 'edition' isa REST {
      $ctx -> stash -> {collection} = 
        OokOok::Collection::Edition -> new(c => $ctx);
    }
  }

  method pages_GET ($ctx) { $self -> collection_GET($ctx) }
  method pages_POST ($ctx) { $self -> collection_POST($ctx) }

  method snippets_GET ($ctx) { $self -> collection_GET($ctx) }
  method snippets_POST ($ctx) { $self -> collection_POST($ctx) }

  method editions_GET ($ctx) { $self -> collection_GET($ctx) }
  method editions_POST ($ctx) { $self -> collection_POST($ctx) }

  method editions_DELETE ($ctx) {
    # this will try to clear out the current working edition of changes
    # essentially revert back to what we had when we closed the last edition
    eval {
      $ctx -> stash -> {project} -> source -> current_edition -> delete;
    };

    if($@) { print STDERR "DELETE ERROR: $@\n"; }

    $self -> status_no_content($ctx);
  }
}
