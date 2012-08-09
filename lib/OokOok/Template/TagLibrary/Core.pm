package OokOok::Template::TagLibrary::Core;

use OokOok::Template::TagLibrary;

# processes content
element 'snippet' => (
  uses_content => 1, # we'll get the node for further processing
  escape_text => 0,
  attributes => {
    "" => {
      name => 'Str', # not an expression
    }
  },
  impl => 'element_snippet',
);

# no child parts
element 'content' => (
  escape_text => 0,
  attributes => {
    "" => {
      part => 'Str', # not an expression
      inherit => 'Bool', # true/false
    }
  },
  impl => 'element_content',
);

element 'if-content' => (
  escape_text => 0,
  uses_content => 1,
  attributes => {
    "" => {
      part => 'Str', # not an expression
      inherit => 'Bool',
    }
  },
  impl => 'element_if_content',
);
  
element 'unless-content' => (
  escape_text => 0,
  uses_content => 1,
  attributes => {
    "" => {
      part => 'Str', # not an expression
      inherit => 'Bool',
    }
  },
  impl => 'element_unless_content',
);
  


sub element_snippet {
  my($self, $context, $attr) = @_;
  my $name = $attr -> {"name"};

  # we want to render the snippet with the current context
  my $project = $context -> get_resource("project");
  if($project) {
    my $snippet = $project -> snippet($name);
    if($snippet) {
      return $snippet -> render($context);
    }
    my $theme = $project -> theme;
    if($theme) {
      $snippet = $theme -> snippet($name);
      if($snippet) {
        return $snippet -> render($context);
      }
    }
  }

  if(!defined($name)) { $name = 'unnamed' }

  my $divClass = "snippet-$name";

  return "<div><!-- Snippet '$name' not found. --></div>";
}

sub element_content {
  my($self, $context, $attr) = @_;
  my $name = $attr -> {"part"};
  if(!defined($name) || $name eq '') {
    if($context -> has_var('content')) {
      return $context -> get_var('content');
    }
    $name = 'body';
  }

  print STDERR "content: [$name]\n";

  my $inherit = $attr -> {'inherit'};

  # we want to render the page part with the current context
  # if the current page doesn't have the named part, then we want
  # to go up the current sitemap until we find it.
  my $page = $context -> get_resource("page");
  if($page) {
    my $page_part = $page -> page_part( $name );
    if($inherit) {
      while($page && !$page_part) {
        $page = $page -> parent_page;
        if($page) {
          $page_part = $page -> page_part( $name );
        }
      }
    }

    if($page_part) {
      return $page_part -> render($context);
    }
  }
  return "<div><!-- Page part '$name' not found. --></div>";
}

sub has_content_q {
  my($self, $context, $attr) = @_;
  my $name = $attr -> {"part"};
  my $has_content;
  if(!defined($name) || $name eq '') {
    if($context -> has_var('content')) {
      $has_content = 1;
    }
    $name = 'body';
  }

  if(!$has_content) {
    my $inherit = $attr -> {'inherit'};

    my $page = $context -> get_resource("page");
    if($page) {
      my $page_part = $page -> page_part( $name );
      if($inherit) {
        while($page && !$page_part) {
          $page = $page -> parent_page;
          if($page) {
            $page_part = $page -> page_part( $name );
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

sub element_if_content {
  my($self, $context, $attr, $yield) = @_;
  if($self -> has_content_q($context, $attr)) {
    return $yield->();
  }
}

sub element_unless_content {
  my($self, $context, $attr, $yield) = @_;
  if(!$self -> has_content_q($context, $attr)) {
    return $yield->();
  }
}

1;
