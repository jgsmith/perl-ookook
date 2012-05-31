#!/usr/bin/env perl

use DBIx::Class::Fixtures;
use Test::More no_plan;

BEGIN {
  use_ok "OokOok::Model::DB";
  use_ok "OokOok::Schema";
}

my $schema = OokOok::Schema -> connect('dbi:SQLite:dbname=:memory:');

ok $schema, "Schema object loads";

#
# Project
#

my $theme_rs = $schema -> resultset("Theme");
my $edition_rs = $schema -> resultset("ThemeEdition");
my $layout_rs = $schema -> resultset("ThemeLayout");

my $theme = $theme_rs ->  create({ });

ok $theme, "We created a theme";

my $instance = $theme -> current_edition;

ok $instance, "We have a current edition for the theme";

#
# Add some layouts
#

# We shouldn't have any pages in the DB when we start.
is scalar($layout_rs->all), 0, "No layouts in the DB";

my $layout = $instance -> create_related('layouts', {
  name => 'Simple',
  layout => {
    width => 12,
    content => [{
      type => 'Box',
      width => 12,
      class => 'header',
      content => [{
        type => 'Snippet',
        content => 'header',
        width => 12,
      }, {
        type => 'Snippet',
        content => 'navigation',
        width => 12,
      }],
    }, {
      type => 'Box',
      width => 12,
      class => 'main-content',
      content => [{
        type => 'PagePart',
        content => 'sidebar',
        width => 3,
      }, {
        type => 'PagePart',
        content => 'body',
        width => 9,
      }]
    }, {
      type => 'Box',
      width => 12,
      class => 'footer',
      content => [{
        type => 'Snippet',
        content => 'footer',
        width => 12,
      }]
    }],
  },
  configuration => {
  },
});

ok $layout, "Layout was created";

my $dom = XML::LibXML::Document->new();

my $c = Fake::Context -> new();

$c -> stash -> {parser} = XML::LibXML->new();

my $doc = $layout -> _render_box($c, $dom, {
  width => 12
});

ok $doc, "We got something back from the rendering";

$dom -> setDocumentElement($doc);

is $dom -> toStringHTML(), qq{<div class="span12"></div>\n}, "Got right HTML out";

$doc = $layout -> _render_box($c, $dom, {
  width => 12,
  content => [{
    type => 'Content',
    content => 'Foo'
  }]
});

$dom -> setDocumentElement($doc);

is $dom -> toStringHTML(), qq{<div class="span12"><div>Foo</div></div>\n}, "Got right HTML out for a content box";





BEGIN {
package Fake::Context;

use Moose;

has 'stash' => (
  isa => 'HashRef',
  is => 'ro',
  default => sub { +{} }
);
}

1;

__END__
