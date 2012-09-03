use CatalystX::Declare;

controller OokOok::Controller::Theme
   extends OokOok::Base::REST
{

  $CLASS -> config(
    map => {
    },
    default => 'text/html',
  );

  under '/' {
    action base as 'theme';
  }

  under resource_base {
    final action editions as "edition" isa REST {
      $ctx -> stash -> {collection} = OokOok::Collection::ThemeEdition ->
                                         new(c => $ctx);
    }
    final action layouts as "theme-layout" isa REST {
      $ctx -> stash -> {collection} = OokOok::Collection::ThemeLayout ->
                                         new(c => $ctx);
    }
    final action styles as "theme-style" isa REST {
      $ctx -> stash -> {collection} = OokOok::Collection::ThemeStyle ->
                                         new(c => $ctx);
    }
  }

  method editions_GET  ($ctx) { $self -> collection_GET($ctx); }
  method editions_POST ($ctx) { $self -> collection_POST($ctx); }

  method editions_DELETE ($ctx) {
    # this will try to clear out the current working edition of changes
    # essentially revert back to what we had when we closed the last edition
    eval {
      $ctx -> stash -> {project} -> source -> current_edition -> delete;
    };

    $ctx -> log -> info("DELETE ERROR: $@") if $@;

    $self -> status_no_content($ctx);
  }

  method layouts_GET  ($ctx) { $self -> collection_GET($ctx); }
  method layouts_POST ($ctx) { $self -> collection_POST($ctx); }

  method layouts_OPTIONS ($ctx) {
    $self -> do_OPTIONS($ctx,
      Allow => [qw/GET OPTIONS POST/],
      Accept => [qw{application/json}],
    );
  }


  method styles_GET  ($ctx) { $self -> collection_GET($ctx); }
  method styles_POST ($ctx) { $self -> collection_POST($ctx); }

  method styles_OPTIONS ($ctx) {
    $self -> do_OPTIONS($ctx,
      Allow => [qw/GET OPTIONS POST/],
      Accept => [qw{application/json}],
    );
  }
}
