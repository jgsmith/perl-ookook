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
      #my @path = @{$ctx -> request -> arguments};

      my $date = $ctx -> stash -> {date};

      # now we walk the sitemap to find the right page
      my $page = $ctx -> stash -> {project} -> page;
      my($slug, $last_page);

      #$last_page = $page;
      while($page && @path) {
        $slug = shift @path;
        $last_page = $page;
        $page = $page -> get_child_page($slug);
        #print STDERR " [$slug] => ", ($page ? $page->id : ''), "\n";
        if(!$page) { unshift @path, $slug; $page = $last_page; }
      }
      #$page = $last_page;

      # we expect as many entries in the stashed path as are in the @path
      # for now, we shouldn't have anything left in @path -- we don't have
      # pages yet that can react to extra path info
      if(!$page || @path) {
        $ctx -> response->body( 'Page not found' );
        $ctx -> response -> status(404);
        $ctx -> detach;
      }

      #print STDERR "Rendering page for ", $page -> id, "\n";

      $ctx -> stash -> {page} = $page;
    }

    final action play_GET (@path) is private {
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

      $ctx -> stash -> {template} = 'view/play.tt2';
      $ctx -> forward( $ctx -> view('HTML') );
    }
  }
}
