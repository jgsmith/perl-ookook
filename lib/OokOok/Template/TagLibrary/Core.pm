package OokOok::Template::TagLibrary::Core;

use OokOok::Template::TagLibrary;

namespace "http://www.ookook.org/ns/core/1.0";

# processes content
element 'snippet' => (
  uses_content => 1, # we'll get the node for further processing
  escape_text => 0,
  attributes => {
    "http://www.ookook.org/ns/core/1.0" => {
      name => 'Str', # not an expression
    }
  },
  impl => 'element_snippet',
);

# no child parts
element 'page-part' => (
  escape_text => 0,
  attributes => {
    "http://www.ookook.org/ns/core/1.0" => {
      name => 'Str', # not an expression
    }
  },
  impl => 'element_page_part',
);

sub element_snippet {
  my($self, $context) = @_;
  my $name = $context -> get_var("name");

  # we want to render the snippet with the current context
  my $project = $context -> get_resource("project");
  if($project) {
    my $snippet = $project -> snippet($name);
    if($snippet) {
      return $snippet -> render($context);
    }
  }

  my $divClass = "snippet-$name";

  return "<div><!-- Snippet '$name' not found. --></div>";
}

sub element_page_part {
  my($self, $context) = @_;
  my $name = $context -> get_var("name");

  # we want to render the page part with the current context
  # if the current page doesn't have the named part, then we want
  # to go up the current sitemap until we find it.
  my $page = $context -> get_resource("page");
  if($page) { 
    my $page_part = $page -> page_part( $name );
    while($page && !$page_part) {
      $page = $page -> parent_page;
      if($page) {
        $page_part = $page -> page_part( $name );
      }
    }

    if($page_part) {
      return $page_part -> render($context);
    }
  }
  return "<div><!-- Page part '$name' not found. --></div>";
}

1;
