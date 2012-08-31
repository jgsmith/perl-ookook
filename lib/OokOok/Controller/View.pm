use CatalystX::Declare;

controller OokOok::Controller::View
   extends OokOok::Base::Player
{

  $CLASS -> config(
    map => {
      'text/html' => [ 'View', 'HTML' ],
    },
    default => 'text/html',
  );

  under '/' {
    action base as 'v' {
      $ctx -> stash -> {collection} = OokOok::Collection::Project -> new(
        c => $ctx,
      );
    }
  }

  under play_base {
    final action play (@path) as '' isa REST {
      my $date = $ctx -> stash -> {date};

      # now we walk the sitemap to find the right page
      my $page = $ctx -> stash -> {project} -> page;
      my($slug, $last_page);

      while($page && @path) {
        $slug = shift @path;
        $last_page = $page;
        $page = $page -> get_child_page($slug);
        if(!$page) { 
          unshift @path, $slug; 
          $page = $last_page; 
          last;
        }
      }

      # we expect as many entries in the stashed path as are in the @path
      # for now, we shouldn't have anything left in @path -- we don't have
      # pages yet that can react to extra path info
      if(!$page || @path) {
        $ctx -> response->body( 'Page not found' );
        $ctx -> response -> status(404);
        $ctx -> detach;
      }

      $ctx -> stash -> {page} = $page;
    }
  }

  method play_GET ($ctx, @path) {
    my $context = OokOok::Template::Context -> new(
      c => $ctx
    );

    my $page = $ctx -> stash -> {page};
    $context -> set_resource(page => $page);
    $context -> set_resource(project => $ctx -> stash -> {project});

    $ctx -> stash -> {rendering} = $page -> render($context);
    my $project_uuid = $page -> project -> source -> uuid;
    $ctx -> stash -> {stylesheets} = [ map {
      $ctx -> uri_for( "/s/$project_uuid/style/$_" )
    } $page -> stylesheets ];

    if($page -> date) {
      my $date = $page -> source_version -> edition -> closed_on;
      my $root = "/";
      if($ctx -> stash -> {date}) {
        #$root .= "../";
      }
      local $URI::ABS_REMOTE_LEADING_DOTS = 1;
      my $url = URI->new($root
              . $date -> ymd('') . $date -> hms('') 
              .  "/v/$project_uuid/" . ($page -> slug_path || ''))
          -> abs($ctx -> uri_for("/"));
      $ctx -> stash -> {canonical_url} = $url -> as_string;
    }

    $ctx -> stash -> {template} = 'view/play.tt2';
    $ctx -> forward( $ctx -> view('HTML') );
  }
}
