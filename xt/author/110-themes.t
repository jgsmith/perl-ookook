#!/usr/bin/env perl

use XML::LibXML;
use Test::More;

BEGIN {
  $ENV{'OOKOOK_CONFIG_LOCAL_SUFFIX'} = "testing";
}

BEGIN {
  use_ok "OokOok";
  use_ok "OokOok::Model::DB";
  use_ok "OokOok::Schema";
}

my $schema = OokOok -> model("DB");

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

my $layout = $theme -> create_related('theme_layouts', {});
ok $layout, "Layout was created";

my $layout_version = $layout->current_version;

$layout_version -> update({
  name => 'Simple',
  layout => <<'EOXML',
<div></div>
EOXML
});


my $dom = XML::LibXML::Document->new();

my $stash = {};

$stash -> {parser} = XML::LibXML->new;

my $layoutXml = XML::LibXML -> load_xml(string => <<'EOXML');
<div></div>
EOXML

done_testing();
