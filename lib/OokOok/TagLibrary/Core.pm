use OokOok::Declare;

# PODNAME: OokOok::TagLibrary::Core

# ABSTRACT: Core tags for layouts, pages, and such

taglib OokOok::TagLibrary::Core {

  under theme {

    element asset (Str :$name) is yielding returns HTML {
      "<!-- theme:asset -->" . $yield -> ()
    }

    under asset {

      element link (Str :$title?) returns HTML {
        "<!-- theme:asset:link -->"
      }

      element image (Str :$title?) returns HTML {
        "<!-- theme:asset:image -->"
      }

    }

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
    $page ? $page -> slug_path : '';
  }

  documentation <<'EOD';
Causes the tags referring to a page’s attributes to refer to the current page.

Usage

    <%tag%>...</%tag%>
EOD

  # TODO: make sure context stores the actual page we're rendering
  element page is yielding returns HTML {
    return '';
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
      my $url = $page -> slug_path;
      # need to handle date aspect of URLs
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
    if($self -> has_content_q($ctx, part => $part, inherit => $inherit)) {
      return $yield->();
    }
    return '';
  }

  element unless_content (Str :$part?, Bool :$inherit?) as "unless-content" is yielding returns HTML {
    $part = ${$part||[]}[0];
    $inherit = ${$inherit||[]}[0];
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
