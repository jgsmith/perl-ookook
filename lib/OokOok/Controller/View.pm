use OokOok::Declare;

# PODNAME: OokOok::Controller::View

# ABSTRACT: provides processed view of project pages

play_controller OokOok::Controller::View {

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

      # if the current dev/date doesn't map to an edition, then
      # we can't very well find the right page
      if(!$ctx -> stash -> {project} -> source_version) {
        $ctx -> detach(qw/Controller::Root default/);
      }

      # closed editions are considered published (i.e., publicly readable)
      # the edition resource
      if(!$ctx -> stash -> {project} -> can_PLAY) {
        $ctx -> detach(qw/Controller::Root default/);
      }

      # now we walk the sitemap to find the right page
      my $page = $ctx -> stash -> {project} -> home_page;
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
        $ctx -> detach(qw/Controller::Root default/);
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
    } grep {
      defined
    } $page -> stylesheets ];

    if($page -> date) {
      my $date = $page -> source_version -> edition -> closed_on;
      my $root = "/";
      if($ctx -> stash -> {date}) {
        #$root .= "../";
      }
      local $URI::ABS_REMOTE_LEADING_DOTS = 1;
      my $root_uri = $ctx -> uri_for("/");
      my $url = URI->new($root
              . $date -> ymd('') . $date -> hms('') 
              .  "/v/$project_uuid/" . ($page -> slug_path || ''))
          -> abs($root_uri) -> as_string;
      $ctx -> stash -> {canonical_url} = $url;

      # now get other relevant dates for this page
      $ctx -> stash -> {canonical_versions} = [
        map { +{
                 link => URI->new(
                           $root . $_ -> date 
                                 . "/v/$project_uuid/" 
                                 . ($_ -> slug_path || '')
                         ) -> abs($root_uri)
                           -> as_string,
                 date => $self -> _relativeDate( $_ -> date ),
                 full_date => $_ -> date -> format_cldr('y MMM dd hh:mm:ss a'),
              }
            }
        map { OokOok::Resource::Page -> new(
                c => $ctx,
                date => $_ -> edition -> closed_on,
                source => $_ -> owner,
                is_development => 0,
                source_version => $_
              )
            } 
        grep { defined $_ -> edition -> closed_on }
        $page -> source -> versions
      ];
    }

    $ctx -> stash -> {template} = 'view/play.tt2';
    $ctx -> forward( $ctx -> view('HTML') );
  }

    my @dt_methods = qw(
      years a_year_ago
      months a_month_ago
      weeks a_week_ago
      days yesterday
      hours an_hour_ago
      minutes a_minute_ago
    );

    @dt_methods = map { $_ =~ s/_/ /g; $_ } @dt_methods;

  method _relativeDate ($date) {
    my $dur = ($date - DateTime -> now) -> inverse;

    my $i = 0;
    while($i < @dt_methods) {
      my $m = $dt_methods[$i];
      my $v = $dur -> $m;
      if($v > 1) {
        return $v . " " . $dt_methods[$i] . " ago";
      }
      if($v == 1) {
        return $dt_methods[$i+1];
      }
      $i += 2;
    }
    return "less than " . $dt_methods[$#dt_methods];
  }
}
