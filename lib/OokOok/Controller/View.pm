use OokOok::Declare;

# PODNAME: OokOok::Controller::View

# ABSTRACT: provides processed view of project pages

use feature 'switch';

play_controller OokOok::Controller::View {

  use HTML::Entities qw(encode_entities);
  use Encode qw(encode_utf8);
  use OokOok::Util::Serialization qw(to_link_format);

  __PACKAGE__ -> config(
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
    final action play (@path) as '' {
      given($ctx -> stash -> {mode}) {
        when('timegate') { $self -> play_timegate($ctx, @path) }
        when('timemap')  { $self -> play_timemap($ctx, @path) }
        default          { $self -> play_view($ctx, @path) }
      }
    }
  }

  method gather_times($ctx, @path) {
    my $project = $ctx -> stash -> {project} -> source;
    my @times = $project -> home_pages;

    while(@path) {
      @times = map {
        $project -> child_page_versions(shift(@path), @$_);
      } @times;
    }

    @times;
  }

  method play_timegate($ctx, @path) {
    my $project = $ctx -> stash -> {project};
    my $project_uuid = $project -> id;
    my @links = ({
      link => $ctx -> uri_for('/') . 'timegate/v/' . $project_uuid . '/' . join("/", @path),
      rel => 'timegate self',
    }, {
      link => $ctx -> uri_for('/') . 'timemap/v/' . $project_uuid . '/' . join("/", @path),
      rel => 'timemap',
    }, {
      link => $ctx -> request -> uri,
      rel => 'original',
    });

    $ctx -> response -> body(to_link_format(@links));
    $ctx -> response -> content_type("application/link-format");
    $ctx -> response -> status(200);
  }

  method play_timemap($ctx, @path) {
    my $project = $ctx -> stash -> {project};
    my $project_uuid = $project -> id;
    my @links = ({
      link => $ctx -> uri_for('/') . 'timemap/v/' . $project_uuid . '/' . join("/", @path),
      rel => 'timemap self',
    }, {
      link => $ctx -> uri_for('/') . 'timegate/v/' . $project_uuid . '/' . join("/", @path),
      rel => 'timegate',
    }, {
      link => $ctx -> request -> uri,
      rel => 'original',
    });

    my @times = $self -> gather_times($ctx, @path); #$project -> source -> home_pages;

    @times =
      sort {
        $a -> [2] cmp $b -> [2]
      } map {
        [ @$_, $_->[1] -> start -> ymd('') . $_->[1] -> start -> hms('') ]
      } @times
    ;

    # now we can walk @path

    my $url = '/v/'.$project_uuid.'/'.join('/', @path);
    my $root_url = $ctx -> uri_for('/');
    push @links, map { +{
      link => $root_url . $_->[2] . $url,
      rel => 'memento',
      datetime => $_->[1]->start->strftime("%a, %d %b %Y %H:%M:%S %z"),
    } } @times;

    if(@links > 3) {
      $links[3]->{rel} .= " first";
      $links[$#links]->{rel} .= " last";
    }

    $ctx -> response -> body(to_link_format(@links));
    $ctx -> response -> content_type("application/link-format");
    $ctx -> response -> status(200);
  }

  method calculate_body ($ctx, $page) {
    my $context = OokOok::Template::Context -> new(
      c => $ctx
    );

    $context -> set_resource(page => $page);
    $context -> set_resource(top_page => $page);
    $context -> set_resource(project => $ctx -> stash -> {project});
    $page -> render($context);
  }

  method play_view($ctx, @path) {
    my $date = $ctx -> stash -> {date};
    my $project = $ctx -> stash -> {project};

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
    if(!$page || @path || !defined($page -> source_version)) {
      $ctx -> detach(qw/Controller::Root default/);
    }

    $ctx -> stash -> {page} = $page;

    my $acc = '';
    my $writer = sub {
      #$ctx -> response -> write(encode_utf8($_[0]));
      $acc .= $_[0];
    };

    my $committer = sub {
      $ctx -> response -> write(encode_utf8($acc));
      $acc = '';
    };

    $ctx -> response -> status(200);
    $ctx -> response -> content_type("text/html; charset=utf-8");

    $writer->(qq{<html lang="en">\n<head>});

    $writer->("<title>" . encode_entities($project -> name . " - " . $page -> title) . "</title>");

    my $project_uuid = $page -> project -> source -> uuid;

    my $canonical_url;
    my $root = "/";
    my $root_uri = $ctx -> uri_for("/");
    #my $date = $page -> source_version -> edition -> closed_on;
    $date = $page -> source_version -> edition -> closed_on;

    if($page -> date) {
      local $URI::ABS_REMOTE_LEADING_DOTS = 1;
      $canonical_url = URI->new($root
              . $date -> ymd('') . $date -> hms('') 
              .  "/v/$project_uuid/" . ($page -> slug_path || ''))
          -> abs($root_uri) -> as_string;

      $writer->(qq{<link rel="canonical" href="$canonical_url" />});
    }

    $writer->(join("\n", map {
      qq{<link href="$_" rel="stylesheet/less" type="text/css">}
    }  map {
      $ctx -> uri_for( "/s/$project_uuid/style/$_" )
    } keys %{ +{
      map { ($_ => 1) } 
      grep { defined } 
      $page -> stylesheets
    } }));

    $writer->(q{<link href="/static/css/player.less" type="text/css" rel="stylesheet/less">
<script src="/static/js/less-1.3.0.min.js" type="text/javascript"></script>});
    $writer->("\n<!-- time: ".$project->date." -->\n");

    $writer->(q{</head><body><div id="ookook-rendering" class="hyphenate">});

    if($page -> status > 0) {
      $writer->(q{<img src="/static/images/demo.png" style="position: absolute; top: 100; left: 100;" />});
    }

    my $cache_body;
    my $calculated_body;
    my $key;
    my $cache;

    $committer -> ();

    if($ctx -> stash -> {mode} eq 'development' || $ctx -> stash -> {project} -> is_development) {
      $writer->($self -> calculate_body($ctx, $page));
    }
    else {
      $cache = $ctx -> model('Cache');
      $key = $project -> date . $project -> id . $page -> id;
      my $b = $cache -> get($key);
      if(!defined($b)) {
        $cache_body = 1;
        $calculated_body = $self -> calculate_body($ctx, $page);
        $b = $calculated_body;
      }
      $writer->($b);
    }

    $writer->(q{</div><div id="ookook-apparatus"><div id="ookook-apparatus-body" style="display: none;" class="hyphenate">});

    $committer -> ();

    if($page -> date) {
      # now get other relevant dates for this page
      my @versions =
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
      ;

      for my $v (@versions) {
        $v->{a} = qq{<a href="$v->{link}" title="$v->{full_date}">$v->{date}</a>};
      }

      if(@versions) {
        $writer->("<h1>Versions</h1>" . join("<br/>",
          map { 
            if($_->{link} eq $canonical_url) {
              "<strong>" . $_->{a} . "</strong>"
            } else {
              $_->{a}
            }
          } @versions
        ));
      }
    }

    $writer->(q{</div><div id="ookook-apparatus-handle"><a href="#">OokOok!</a></div></div>});

    $writer->(<<EOHTML);
<script src="/static/js/combined-player.js" type="text/javascript"></script>
<!-- script src="/static/js/Hyphenator.js" type="text/javascript"></script -->
<script type="text/javascript">
Hyphenator.config({
  persistentconfig: true,
  storagetype: 'local',
  useCSS3hyphenation: true,
  displaytogglebox : false,
  minwordlength : 4
});
Hyphenator.run();
</script>
<!-- script src="/static/js/jquery-1.8.2.min.js" type="text/javascript"></script>
<script src="/static/js/player.js" type="text/javascript"></script -->
<script>
// replace 'en' with the language of the project page
function googleTranslateElementInit() {
  new google.translate.TranslateElement({
    pageLanguage: 'en'
  });
}
</script><script src="http://translate.google.com/translate_a/element.js?cb=googleTranslateElementInit"></script>
</body></html>
EOHTML

    $committer -> ();

    $ctx -> response -> body('');
    if($cache_body) {
      $cache -> set($key, $calculated_body);
    }

    return 1;
  }

  my @dt_methods = map { s/_/ /g; $_ } @{[qw(
    years   a_year_ago
    months  a_month_ago
    weeks   a_week_ago
    days    yesterday
    hours   an_hour_ago
    minutes a_minute_ago
  )]};

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
