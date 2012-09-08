use strict;
use warnings;
use Test::More;

BEGIN {
  $ENV{'OOKOOK_CONFIG_LOCAL_SUFFIX'} = "testing";
}

use OokOok::ForTesting::REST;
use OokOok::Controller::Theme;

ok( request('/theme')->is_success, 'Request should succeed' );

# set up a theme with two layouts: one to test snippets, and one to
#  test page parts (body page part for now)

my $json = POST_ok('/theme', {
  name => 'Test Theme',
  description => 'Theme for testing.',
}, "Create a theme");

my $uuid = $json -> {id};
my $theme_url = $json -> {_links} -> {self};

ok $uuid, "Theme has an id";
is $json->{name}, "Test Theme", "Right name";
is $json->{description}, "Theme for testing.", "Right description";

my $snippet_layout = <<EOXML;
<r:snippet r:name="header" />
EOXML

$json = POST_ok("/theme/$uuid/theme-layout", {
  name => 'Snippet',
  layout => $snippet_layout,
}, "Create a snippet layout");

my $snippet_layout_uuid = $json->{id};
ok $snippet_layout_uuid;
is $json->{name}, "Snippet", "Right name";
is $json->{layout}, $snippet_layout, "Right layout";

my $body_layout = <<EOXML;
<r:content r:part="body" />
EOXML

$json = POST_ok("/theme/$uuid/theme-layout", {
  name => 'Body',
  layout => $body_layout,
}, "Create a body layout");

my $body_layout_uuid = $json->{id};
ok $body_layout_uuid;
is $json->{name}, "Body", "Right name";
is $json->{layout}, $body_layout, "Right layout";

# now make sure the theme lists both layouts

$json = GET_ok("/theme/$uuid", "Get theme");

is @{$json->{_embedded}->{theme_layouts}}, 2, "Two layouts in theme";

sleep(1);

POST_ok("/theme/$uuid/edition", {}, "Close theme edition");

# then create a project using that theme
$json = POST_ok("/project", {
  name => "Test",
  description => "Testing layouts",
  theme => $uuid,
  theme_date => DateTime->now->iso8601
}, "Create project");

my $project_uuid = $json -> {id};

ok $project_uuid, "Project has id";
is $json -> {_links} -> {theme}, $theme_url, "Right theme URL";

my $page_url = $json -> {_links} -> {home_page};
ok $page_url, "We have a root page for the project";

$json = POST_ok($page_url . "/page-part/body", {
  content => "<p>Page Body</p>"
}, "Add a body page part to the page");

is $json->{_links}->{self}, "$page_url/page-part/body", "Right url";

$json = GET_ok($page_url . "/page-part/body", "Get body page part");
is $json->{content}, "<p>Page Body</p>", "Right content";

# now we want to modify the page to get the right layout
$json = PUT_ok($page_url, {
  layout => $body_layout_uuid,
}, "Set layout for page");

is $json->{layout}, $body_layout_uuid, "Right layout set";

# now we can try rendering the page and see if we get the right content

my $req = request("/dev/v/$project_uuid/");
ok( $req->is_success, "Get page");

#diag $req -> content;
my $content = $req -> content;

like $content, qr/<p>Page Body<\/p>/, "Right content";

#
# Now try snippets
#

POST_ok("/project/$project_uuid/snippet", {
  name => "header",
  content => "<p>Heading</p>"
}, "Add header snippet");

$json = PUT_ok($page_url, {
  layout => $snippet_layout_uuid,
}, "Set layout for page to snippet layout");

is $json->{layout}, $snippet_layout_uuid, "Right layout set";

$req = request("/dev/v/$project_uuid/");
ok( $req->is_success, "Get page");

#diag $req -> content;
$content = $req -> content;

like $content, qr/<p>Heading<\/p>/, "Right content";

done_testing();
