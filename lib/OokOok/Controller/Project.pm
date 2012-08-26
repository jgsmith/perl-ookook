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

  action base under '/' as 'project' {
    if($ctx -> stash -> {development} || $ctx -> stash -> {date}) {
      $ctx -> detach(qw/Controller::Root default/);
    }

    $ctx -> stash -> {development} = 1; # for use by resources/collections

    $ctx -> stash -> {collection} = OokOok::Collection::Project -> new(c => $ctx);
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

    final action pages_GET is private { shift -> collection_GET(@_) }
    final action pages_POST is private { shift -> collection_POST(@_) }

    final action snippets_GET is private { shift -> collection_GET(@_) }
    final action snippets_POST is private { shift -> collection_POST(@_) }

    final action editions_GET is private { shift -> collection_GET(@_) }
    final action editions_POST is private { shift -> collection_POST(@_) }

    final action editions_DELETE is private {
      # this will try to clear out the current working edition of changes
      # essentially revert back to what we had when we closed the last edition
      eval {
        $ctx -> stash -> {project} -> source -> current_edition -> delete;
      };
  
      if($@) { print STDERR "DELETE ERROR: $@\n"; }
  
      $self -> status_no_content($ctx);
    }
  }
}
