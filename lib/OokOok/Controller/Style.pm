use OokOok::Declare;

# PODNAME: OokOok::Controller::Style

# ABSTRACT: Style Provider for Project Viewing

play_controller OokOok::Controller::Style {

  $CLASS -> config(
    map => {
      'text/css' => [ 'View', 'CSS' ],
    },
    default => 'text/css',
  );

  under '/' {
    action base as 's' {
      $ctx -> stash -> {collection} = OokOok::Collection::Project -> new(
        c => $ctx,
      );
    }

    action tbase as 'ts' {
      $ctx -> stash -> {collection} = OokOok::Collection::Theme -> new(
        c => $ctx,
        is_development => 1,
      );
    }
  }

  under tbase {
    action play_tbase ($uuid) as '' {
      $self -> play_base($ctx, $uuid);
    }
  }

  under play_tbase {
    action tstyle_base ($uuid) as 'style' {
      my $theme = $ctx -> stash -> {theme};

      # closed editions are considered published (i.e., publicly readable)
      # the edition resource
      if(!$theme -> can_PLAY) {
        $ctx -> log -> info("Can't play theme");
        $ctx -> detach(qw/Controller::Root default/);
      }

      my $style = $theme -> style($uuid);

      if(!$style) {
        $ctx -> detach(qw/Controller::Root default/);
      }

      $ctx -> stash -> {resource} = $style;
    }

    action tasset_base ($uuid) as 'asset' {
      my $theme = $ctx -> stash -> {theme};

      if(!$theme -> can_PLAY) {
        $ctx -> log -> info("Can't play theme");
        $ctx -> detach(qw/Controller::Root default/);
      }

      my $asset = $theme -> asset($uuid);

      if(!$asset) {
        $ctx -> detach(qw/Controller::Root default/);
      }

      $ctx -> stash -> {resource} = $asset;
    }
  }

  under tstyle_base {
    final action tstyle as '' isa REST;
  }

  under play_base {
    action style_base ($uuid) as 'style' {
      # closed editions are considered published (i.e., publicly readable)
      # the edition resource
      if(!$ctx -> stash -> {project} -> can_PLAY) {
        $ctx -> log -> info("Can't play project");
        $ctx -> detach(qw/Controller::Root default/);
      }

      my $theme = $ctx -> stash -> {project} -> theme;
      my $style = $theme -> style($uuid);

      if(!$style) {
        $ctx -> detach(qw/Controller::Root default/);
      }


      $ctx -> stash -> {resource} = $style;
    }

    action asset_base ($uuid) as 'asset' {
      # closed editions are considered published (i.e., publicly readable)
      # the edition resource
      if(!$ctx -> stash -> {project} -> can_PLAY) {
        $ctx -> log -> info("Can't play project");
        $ctx -> detach(qw/Controller::Root default/);
      }

      my $theme = $ctx -> stash -> {project} -> theme;
      my $asset = $theme -> asset($uuid);

      if(!$asset) {
        $ctx -> detach(qw/Controller::Root default/);
      }

      # now see if the project has an asset by the same name... if so,
      # substitute
      my $passet = $ctx -> stash -> {project} -> asset( $asset -> name );

      $asset = $passet if $passet;

      $ctx -> stash -> {resource} = $asset;
    }
  }

  under style_base {
    final action style as '' isa REST;
  }

  method calculate_style ($ctx) {
    my $context = OokOok::Template::Context -> new(
      c => $ctx
    );
    if($ctx -> stash -> {project}) {
      $context -> set_resource(project => $ctx -> stash -> {project});
    }
    $ctx -> stash -> {resource} -> render($context);
  }
    

  method style_GET ($ctx) {
    my $body;
    my $load_cache;
    my $key;
    my $cache = $ctx -> model('Cache');
    if($ctx -> stash -> {is_development} || !$ctx -> stash -> {project}) {
      $body = $self -> calculate_style($ctx);
    }
    else {
      if($ctx -> stash -> {project}) {
        my $project = $ctx -> stash -> {project};
        $key = $project -> theme_date . $project -> id . $project -> theme -> id;
      }
        
      $key .= $ctx -> stash -> {resource} -> id;
      $body = $cache -> get($key);
      if(!defined($body)) {
        $body = $self -> calculate_style($ctx);
        $load_cache = 1;
      }
      #$body = $ctx -> model('Cache') -> compute(
      #  $key, sub { $self -> calculate_style($ctx) }
      #);
    }
    $ctx -> response -> status(200);
    $ctx -> response -> content_type("text/plain");
    $ctx -> response -> content_length(length($body));
    $ctx -> response -> write($body);
    $ctx -> response -> body('');
    if($load_cache) {
      $cache -> set($key, $body);
    }
    return 1;
  }

  method tstyle_GET ($ctx) {
    $self -> style_GET($ctx);
  }

  under asset_base {
    final action asset as '' isa REST;
  }

  method asset_GET ($ctx) {
    my $asset = $ctx -> stash -> {resource};
    my $gridfs_file = $ctx -> model('MongoDB') -> get_file(
      theme_asset => $asset -> source_version -> file_id
    );
    if(!$gridfs_file) {
      $ctx -> detach(qw/Controller::Root default/);
    }
    $ctx -> response -> status(200);
    $ctx -> response -> content_type( $asset -> mime_type );
    $ctx -> response -> content_length( $asset -> size );
    $ctx -> response -> body( $gridfs_file -> slurp ); # safest for now
    return 1;
  }

  method tasset_GET ($ctx) {
    $self -> asset_GET($ctx);
  }
}
