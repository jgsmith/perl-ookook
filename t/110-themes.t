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

my $layout = $theme -> create_related('layouts', {});
ok $layout, "Layout was created";

my $layout_version = $layout->current_version;

$layout_version -> update({
  name => 'Simple',
  layout => <<'EOXML',
<row>
  <div width="12">
    <snippet name="header" />
  </div>
</row>
<row>
  <div width="12">
    <snippet name="navigation" />
  </div>
</row>
<row>
  <div width="9">
    <page-part name="sidebar" />
  </div>
  <div width="3">
    <page-part name="sidebar" />
  </div>
</row>
<row>
  <div width="12">
    <snippet name="footer" />
  </div>
</row>
EOXML
  configuration => '{}'
});


my $dom = XML::LibXML::Document->new();

my $stash = {};

$stash -> {parser} = XML::LibXML->new;

my $layoutXml = XML::LibXML -> load_xml(string => <<'EOXML');
<layout>
  <row>
    <div width="12"></div>
  </row>
</layout>
EOXML

my $doc = $layout -> _render_box($stash, $dom, $layoutXml->documentElement);

ok $doc, "We got something back from the rendering";

$dom -> setDocumentElement($doc);

diag $dom -> toStringHTML();

is $dom -> toStringHTML(), qq{<div><div class="row"><div class="span12"></div></div></div>\n}, "Got right HTML out";

#$doc = $layout -> _render_box($stash, $dom, {
  #width => 12,
  #content => [{
    #type => 'Content',
    #content => 'Foo'
  #}]
#});

#$dom -> setDocumentElement($doc);

#is $dom -> toStringHTML(), qq{<div class="span12"><div>Foo</div></div>\n}, "Got right HTML out for a content box";
