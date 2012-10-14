use OokOok::Declare;

# PODNAME: OokOok::TagLibrary::Core

# ABSTRACT: Core tags for layouts, pages, and such

taglib OokOok::TagLibrary::Core {

  use Digest::MD5 qw(md5_hex);
  use File::Spec::Unix ();

  element random is structured returns HTML {
    # we always return the same option for a given date/time
    # this ensures reproducability
    my $count = scalar(@{$children -> {option} || []});
    return '' if $count < 1;

    return $children -> {option} -> [0] -> () if $count == 1;

    my $project = $ctx -> get_resource('project');
    my $date = $project -> date || DateTime -> now;
    my $n = hex(substr(md5_hex($date -> iso8601 . $project -> id), 0, 8));
    print STDERR "Random: $n\nCount: $count\n";
    $n = $n % $count;
    $children -> {option} -> [$n] -> ();
  }

  under random {
    element option is yielding returns HTML { $yield -> (); }
  }

  documentation <<'EOD';
Renders a trail of breadcrumbs to the current page. The separator attribute
specifies the HTML fragment that is inserted between each of the breadcrumbs. By
default it is set to >. The boolean nolinks attribute can be specified to render
breadcrumbs in plain text, without any links (useful when generating title tag).

Usage

    <%tag% [%ns%:separator="separator_string"] [%ns%:nolinks="true"]/>
EOD

  element breadcumbs (Str :$separator = ' &gt; ', Bool :$nolinks?) returns HTML {
    my $page = $ctx -> get_resource("page");
    my @crumbs;
    my $title;

    while($page) {
      $title = $page -> title;
      $title =~ s{&}{&amp;}g;
      $title =~ s{<}{&lt;}g;
      $title =~ s{>}{&gt;}g;
      if($nolinks) {
        push @crumbs, $title;
      }
      else {
        push @crumbs, '<a href="' . $ctx -> project_url($page -> slug_path) . '">' . $title . '</a>';
      }
      $page = $page -> parent_page;
    }

    join($separator, reverse @crumbs);
  }

  element navigation (Str :$urls) is structured returns HTML {
    my @content;
    my $here_url = $ctx -> get_resource('page') -> slug_path . '/';
    my $normal = $children -> {normal} || [ sub { '' } ];
    my $here = ($children->{here} || $normal) -> [0];
    my $selected = ($children -> {selected} || $normal) -> [0];
    my $between = ($children -> {between} || [ sub { '' } ]) -> [0];
    $normal = $normal -> [0];

    $urls = $urls -> [0];

    for my $bit (split(/\s*\|\s*/, $urls)) {
      $bit =~ m{^(.*)\s*:\s*([^:]*)$};
      my($title, $url) = ($1, $2);
      my $lctx = $ctx -> localize;
      $lctx -> set_var(url => $url);
      $lctx -> set_var(title => $title);

      $url .= '/' unless substr($url, -1, 1) eq '/';

      if($here_url eq $url || $here_url) {
        push @content, $here->($lctx);
      }
      elsif($here_url ne '/' && length($url) > length($here_url) && substr($here_url, 0, length($url)) eq $url) {
        push @content, $selected -> ($lctx);
      }
      else {
        push @content, $normal -> ($lctx);
      }
    }
    if(@content < 2) {
      return @content;
    }
    return join($between -> (), @content);
  }

  under navigation {
    element normal   is yielding returns HTML { $yield -> (); }
    element here     is yielding returns HTML { $yield -> (); }
    element selected is yielding returns HTML { $yield -> (); }
    element between  is yielding returns HTML { $yield -> (); }

    under normal {
      element url   { $ctx -> project_url( $ctx -> get_var('url') ); }
      element title { $ctx -> get_var('title'); }
    }

    under here {
      element url   { $ctx -> project_url( $ctx -> get_var('url') ); }
      element title { $ctx -> get_var('title'); }
    }

    under selected {
      element url   { $ctx -> project_url( $ctx -> get_var('url') ); }
      element title { $ctx -> get_var('title'); }
    }
  }

  method gather_children (Object $ctx, Str :$limit?, Str :$order?) {
    my $page = $ctx -> get_resource('page');
    my @children = $page -> child_pages;
    if($order) {
      @children = map {
        [ $_->title, $_ ]
      } @children;
      if(substr($order, 0, 1) eq 'a') { # ascending
        @children = sort { $a->[0] cmp $b->[0] } @children;
      }
      else {
        @children = sort { $b->[0] cmp $a->[0] } @children;
      }
      @children = map { $_->[1] } @children;
    }
    if($limit && @children > $limit) {
      @children = @children[0..$limit-1];
    }
    grep { defined } @children;
  }

  documentation << 'EOD';
Renders the total number of children.

Usage

    <%tag% />
EOD

  element count returns HTML { scalar($self -> gather_children($ctx)); }

  under children {
    element each (Str :$limit?, Str :$order?) is yielding returns HTML {
      my %args;
      $args{limit} = $limit -> [0] if defined $limit;
      $args{order} = $order -> [0] if defined $order;

      my @children = $self -> gather_children($ctx, %args);
      my $content = '';
      my $lctx = $ctx -> localize;
      $lctx -> set_var(is_first => 1);
      while(@children) {
        my $child = shift @children;
        $lctx -> set_resource(page => $child);
        $lctx -> set_var(is_last => !@children);
        $content .= $yield -> ($lctx);
        $lctx = $ctx -> localize;
        $lctx -> set_var(is_first => 0);
      }
      return $content;
    }

    element first (Str :$order?) is yielding returns HTML {
      my %args;
      $args{order} = $order -> [0] if defined($order);

      my $child = $self -> gather_children($ctx, limit => 1, %args);
      return '' unless $child;

      my $lctx = $ctx -> localize;
      $lctx -> set_resource(page => $child);
      $yield -> ($lctx);
    }

    element last (Str :$order?) is yielding returns HTML {
      my %args;
      $args{order} = $order -> [0] if defined($order);

      my @children = $self -> gather_children($ctx, %args);
      return '' unless @children;

      my $child = $children[$#children];
      my $lctx = $ctx -> localize;
      $lctx -> set_resource(page => $child);
      $yield -> ($lctx);
    }

    under each {
      element if_first as "if-first" is yielding returns HTML {
        $ctx -> get_var('is_first') ? $yield->() : '';
      }

      element unless_first as "unless-first" is yielding returns HTML {
        $ctx -> get_var('is_first') ? '' : $yield->();
      }

      element if_last as "if-last" is yielding returns HTML {
        $ctx -> get_var('is_last') ? $yield->() : '';
      }

      element unless_last as "unless-last" is yielding returns HTML {
        $ctx -> get_var('is_last') ? '' : $yield->();
      }
    }
  }

  element find (Str :$url) is yielding returns HTML {

    my $uri = $url -> [0];
    my $root = "/";
    if(substr($uri, 0, 1) ne "/") {
      return '' unless $ctx -> get_resource("top_page");
      $root = $ctx -> get_resource("top_page") -> slug_path;
      if(substr($root, 0, 1) ne "/") {
        $root = "/$root";
      }
    }

    $uri = File::Spec::Unix->rel2abs($uri, $root);
    my $top = $ctx -> get_resource("project") -> home_page;
    my @bits = grep { $_ ne '' } split('/', $uri);

    my $page = @bits ? $top -> resolve_path( @bits ) : $top;

    return '' unless $page;

    my $lctx = $ctx -> localize;
    $lctx -> set_resource(page => $page);
    $yield -> ($lctx);
  }

  documentation <<'EOD';
Used within a snippet as a placeholder for substitution of child content, when
the snippet is called as a double tag.

Usage (within a snippet):

    <div id="outer">
      <p>before</p>
      <%tag%/>
      <p>after</p>
    </div>

If the above snippet was named "yielding", you could call it from any Page,
Layout or Snippet as follows:

    <%ns%:snippet name="yielding">Content within</%ns%:snippet>

Which would output the following:

    <div id="outer">
      <p>before</p>
      Content within
      <p>after</p>
    </div>

When called in the context of a Page or a Layout, <%tag%/> outputs nothing.
EOD

  element yield returns HTML {
    $ctx -> yield;
  }

  documentation <<'EOD';
Page attribute tags inside this tag refer to the parent of the current page.

Usage

    <%tag%>...</%tag%>
EOD

  element parent is yielding returns HTML {
    my $page = $ctx -> get_resource('page');
    $page = $page ? $page -> parent_page : $page;
    return '' unless $page;

    my $new_ctx = $ctx -> localize;
    $new_ctx -> set_resource(page => $page);
    $yield -> ($new_ctx);
  }

  documentation <<'EOD';
Renders the title attribute of the current page.

Usage

    <%tag%/>
EOD

  element title returns Str {
    my $page = $ctx -> get_resource('page');
    $page ? $page -> title : '';
  }

  documentation <<'EOD';
Renders the slug attribute of the current page.

Usage

    <%tag%/>
EOD

  element slug returns Str {
    my $page = $ctx -> get_resource('page');
    $page ? $page -> slug : '';
  }

  documentation <<'EOD';
Renders the URL attribute of the current page.

Usage

    <%tag%/>
EOD

  # TODO: take into account the date of the resource
  element url returns Str {
    my $page = $ctx -> get_resource('page');
    $page ? $ctx -> project_url($page -> slug_path) : '';
  }

  documentation <<'EOD';
Causes the tags referring to a page’s attributes to refer to the current page.

Usage

    <%tag%>...</%tag%>
EOD

  # TODO: make sure context stores the actual page we're rendering
  element page is yielding returns HTML {
    my $lctx = $ctx -> localize;
    $lctx -> set_resource( page => $ctx -> get_resource('top_page') );
    $yield->($lctx);
  }

  documentation <<'EOD';
Renders the contained elements only if the current contextual page has
a parent, i.e. is not the root page.

Usage

   <%tag%>...</%tag%>
EOD

  element if_parent as "if-parent" is yielding returns HTML {
    my $page = $ctx -> get_resource('page');
    $page && $page -> parent_page ? $yield->() : '';
  }

  documentation <<'EOD';
Renders the contained elements only if the current contextual page has
no parent, i.e. is the root page.

Usage

    <%tag%>...</%tag%>
EOD

  element unless_parent as "unless-parent" is yielding returns HTML {
    my $page = $ctx -> get_resource('page');
    $page ? ($page -> parent_page ? '' : $yield->()) : '';
  }

  documentation <<'EOD';
Renders a link to the page. When used as a single tag it uses the page’s title
for the link name. When used as a double tag the part in between both tags will
be used as the link text. If the `anchor` attribute is passed to the tag it 
will append a pound sign (#) followed by the value of the attribute to
the `href` attribute of the HTML `a` tag—effectively making an HTML anchor.

Usage

    <%tag% [anchor="name"]/>

or

    <%tag% [anchor="name"]>click here</%tag%>
EOD

  # TODO: handle anchor attribute
  element link (Str :$anchor?) is yielding returns HTML {
    my $text = $yield -> ();
    my $page = $ctx -> get_resource('page');
    if($page) {
      if($text eq '') {
        $text = $page -> title;
        # html escape text
      }
      my $url = $ctx -> project_url($page -> slug_path);
      return qq{<a href="$url">$text</a>};
    }
    return '';
  }

  documentation <<'EOD';
Nothing inside a set of comment tags is rendered.

Usage

    <%tag%>...</%tag%>
EOD

  element comment returns HTML { '' }
  
  documentation <<'EOD';
Renders the snippet specified in the name attribute within the context 
of a page.

Usage

    <%tag% name="snippet_name"/>

When used as a double tag, the part in between both tags may be used 
within the snippet itself, being substituted in place of <%ns%:yield/>.
EOD

  element snippet (Str :$name) is yielding returns HTML {
    $name = $name -> [0];

    # we want to render the snippet with the current context
    $ctx -> set_yield($yield);
    my $project = $ctx -> get_resource("project");
    if($project) {
      my $snippet = $project -> snippet($name);
      if($snippet) {
        return $snippet -> render($ctx);
      }
      my $theme = $project -> theme;
      if($theme) {
        $snippet = $theme -> snippet($name);
        if($snippet) {
          return $snippet -> render($ctx);
        }
      }
    }

    if(!defined($name)) { $name = 'unnamed' }

    my $divClass = "snippet-$name";

    return "<!-- Snippet '$name' not found. -->";
  }

  element content (Str :$part?, Bool :$inherit?) returns HTML {
    $part = ${$part||[]}[0];
    $inherit = ${$inherit||[]}[0];
    if(!defined($part) || $part eq '') {
      if($ctx -> has_var('content')) {
        return $ctx -> get_var('content');
      }
      $part = 'body';
    }

    # rendering the page part won't provide access to any content for
    # <r:yield/> that might come from an enclosing element
    $ctx -> yield_nothing;

    # we want to render the page part with the current context
    # if the current page doesn't have the named part, then we want
    # to go up the current sitemap until we find it.
    my $page = $ctx -> get_resource("page");
    if($page) {
      my $page_part = $page -> page_part( $part );
      if($inherit) {
        while($page && !$page_part) {
          $page = $page -> parent_page;
          if($page) {
            $page_part = $page -> page_part( $part );
          }
        }
      }

      if($page_part) {
        return $page_part -> render($ctx);
      }
    }
    return "<!-- Page part '$part' not found. -->";
  }

  element if_content (Str :$part?, Bool :$inherit?) as "if-content" is yielding returns HTML {
    $part = ${$part||[]}[0];
    $inherit = ${$inherit||[]}[0];
    if(!defined($part) || $part eq '') {
      if($ctx -> has_var('content')) {
        return $yield->();
      }
      $part = 'body';
    }
    if($self -> has_content_q($ctx, part => $part, inherit => $inherit)) {
      return $yield->();
    }
    return '';
  }

  element unless_content (Str :$part?, Bool :$inherit?) as "unless-content" is yielding returns HTML {
    $part = ${$part||[]}[0];
    $inherit = ${$inherit||[]}[0];
    if(!defined($part) || $part eq '') {
      if($ctx -> has_var('content')) {
        return '';
      }
      $part = 'body';
    }
    if(!$self -> has_content_q($ctx, part => $part, inherit => $inherit)) {
      return $yield->();
    }
    return '';
  }

  documentation <<'EOD';
Escapes angle brackets, etc. for rendering in an HTML document.

Usage

    <%tag%>...</%tag%>
EOD

  # By declaring that we return a non-HTML string, we'll get
  # everything escaped
  element escape_html as "escape-html" is yielding returns Str {
    $yield -> ();
  }

  element if_dev as "if-dev" is yielding returns HTML {
    if($self -> is_dev_q($ctx)) {
      return $yield->();
    }
    return '';
  }

  element unless_dev as "unless-dev" is yielding returns HTML {
    if(!$self -> is_dev_q($ctx)) {
      return $yield->();
    }
    return '';
  }

  element if_children as "if-children" is yielding returns HTML {
    if($self -> has_children_q($ctx)) {
      return $yield->();
    }
    return '';
  }

  element unless_children as "unless-children" is yielding returns HTML {
    if(!$self -> has_children_q($ctx)) {
      return $yield->();
    }
    return '';
  }

  method is_dev_q ($ctx) { $ctx -> is_mockup; }

  method has_content_q ($ctx, Str :$part?, Bool :$inherit?) {
    my $has_content;
    if(!defined($part) || $part eq '') {
      if($ctx -> has_var('content')) {
        $has_content = 1;
      }
      $part = 'body';
    }

    if(!$has_content) {
      my $page = $ctx -> get_resource("page");
      if($page) {
        my $page_part = $page -> page_part( $part );
        if($inherit) {
          while($page && !$page_part) {
            $page = $page -> parent_page;
            if($page) {
              $page_part = $page -> page_part( $part );
            }
          }
        }

        if($page_part) {
          $has_content = 1;
        }
      }
    }
    return $has_content;
  }

  method has_children_q ($ctx) {
    my $page = $ctx -> get_resource("page");
    0 < $page -> child_pages;
  }

}
