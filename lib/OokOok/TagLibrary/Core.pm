use OokOok::Declare;

# PODNAME: OokOok::TagLibrary::Core

taglib OokOok::TagLibrary::Core {

  element parent is yielding returns HTML {
    my $page = $ctx -> get_resource('page');
    $page = $page ? $page -> parent_page : $page;
    return '' unless $page;

    my $new_ctx = $ctx -> localize;
    $new_ctx -> set_resource(page => $page);
    $yield -> ($new_ctx);
  }

  element title returns Str {
    my $page = $ctx -> get_resource('page');
    $page ? $page -> title : '';
  }

  element slug returns Str {
    my $page = $ctx -> get_resource('page');
    $page ? $page -> slug : '';
  }

  # TODO: take into account the date of the resource
  element url returns Str {
    my $page = $ctx -> get_resource('page');
    $page ? $page -> slug_path : '';
  }

  # TODO: make sure context stores the actual page we're rendering
  element page is yielding returns HTML {
    return '';
  }

  element has_parent as "has-parent" is yielding returns HTML {
    my $page = $ctx -> get_resource('page');
    $page && $page -> parent_page ? $yield->() : '';
  }
      
  element unless_parent as "unless-parent" is yielding returns HTML {
    my $page = $ctx -> get_resource('page');
    $page ? ($page -> parent_page ? '' : $yield->()) : '';
  }

  element link is yielding returns HTML {
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

  element comment returns HTML { '' }
  
  element snippet (Str :$name) is yielding returns HTML {
    $name = $name -> [0];

    # we want to render the snippet with the current context
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
