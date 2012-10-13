use CatalystX::Declare;

# PODNAME: OokOok::Declare::Base::REST

# ABSTRACT: Base class for REST controller classes

controller OokOok::Declare::Base::REST
   extends Catalyst::Controller::REST
{

  use Module::Load ();

  method do_OPTIONS ($ctx, %headers) {
    $ctx -> response -> status(200);
    $ctx -> response -> headers -> header(%headers);
    $ctx -> response -> body('');
    $ctx -> response -> content_length(0);
    $ctx -> response -> content_type("text/plain");
    $ctx -> detach();
  }

  # namespace should be set in the inheriting controller
  action base_config as '' under base {
    if($ctx -> stash -> {development} || $ctx -> stash -> {date}) {
      $ctx -> detach(qw/Controller::Root default/);
    }

    $ctx -> stash -> {development} = 1;
    my $collection_class = $self -> config -> {'collection_class'};
    if(!$collection_class) {
      $collection_class = ref $self || $self;
      $collection_class =~ s{::Controller::(.*::)?}{::Collection::};
    }

    eval { Module::Load::load($collection_class) };

    if($@) {
      warn "Unable to load $collection_class for ", (ref($self)||$self), "\n";
    }
    else {
      $ctx -> stash -> {collection} = $collection_class -> new(c => $ctx);
    }
  }

  under base_config {
    final action collection as '' isa REST;

    action resource_base ($id) as '' {
      my $resource = $ctx -> stash -> {collection} -> resource($id);
      if(!$resource) {
        $self -> status_not_found($ctx,
          message => "Resource not found."
        );
        $ctx -> detach;
      }
    
      $ctx -> stash -> {resource} = $resource;
      my $rnom = $resource -> resource_name;
      $ctx -> stash -> {$rnom} = $resource;
    }
  }

  under resource_base {
    final action resource as '' isa REST;
  }

  method collection_GET ($ctx) {
    $self -> status_ok($ctx,
      entity => $ctx -> stash -> {collection} -> _GET(1)
    );
  }

  method collection_POST ($ctx) {
    my $manifest = $ctx -> stash -> {collection} -> _POST($ctx -> req -> data);
    if($manifest) {
      $self -> status_created($ctx,
        location => $manifest->link,
        entity => $manifest -> _GET(1)
      );
    }
    else {
      $ctx -> response -> status(500);
      $ctx -> log -> debug( "Unable to create resource for " . (ref $self || $self) );
      $self -> _set_entity( $ctx, { error => 'Unable to create resource' } );
      return 1;
    }
  }

  method collection_OPTIONS ($ctx) {
    $self -> do_OPTIONS($ctx,
      Allow => [qw/GET OPTIONS POST/],
      Accept => [qw{application/json}],
    );
  }

  method resource_GET ($ctx) {
    $self -> status_ok($ctx,
      entity => $ctx -> stash -> {resource} -> _GET(1)
    );
  }

  method resource_PUT ($ctx) {
    my $resource = $ctx -> stash -> {resource} -> _PUT($ctx -> req -> data);
    $self -> status_ok($ctx,
      entity => $resource -> _GET(1)
    );
  }

  method resource_DELETE ($ctx) {
    if($ctx -> stash -> {resource} -> _DELETE) {
      $self -> status_no_content($ctx);
    }
    else {
      $self -> status_forbidden($ctx,
        message => "Unable to delete resource."
      );
    }
  }

  method resource_OPTIONS ($ctx) {
    $self -> do_OPTIONS($ctx,
      Allow => [qw/GET OPTIONS PUT DELETE/],
      Accept => [qw{application/json}],
    );
  }
}
