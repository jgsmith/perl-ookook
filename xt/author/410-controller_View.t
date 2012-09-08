use strict;
use warnings;
use Test::More;
use HTTP::Request::Common;
use JSON;

BEGIN {
  $ENV{'OOKOOK_CONFIG_LOCAL_SUFFIX'} = "testing";
}

use OokOok::ForTesting::REST;
use OokOok::Controller::View;

my $json;

#
# Create an empty theme
#

$json = POST_ok("/theme", {
    name => 'Test Theme',
  }, "Create theme");

my $theme_uuid = $json -> {id};
ok $theme_uuid, "We have a theme uuid";
my $theme_date = DateTime->now->iso8601;

#
# Create project and populate with sitemap
#

my $uuid;

$json = POST_ok("/project", {
  name => "Test Project",
  description => "Test project description",
  theme => $theme_uuid,
  theme_date => $theme_date,
}, "create project");

$uuid = $json -> {id};

#
# Now we need to add a few pages to the project
#

$json = GET_ok("/project/$uuid/page", "Get list of pages");

ok $json->{_embedded}, "JSON has pages property";
is scalar(@{$json->{_embedded}}), 1, "One page in project";

my %pages;

for my $nom (qw/Foo Bar Baz/) {

  $json = POST_ok("/project/$uuid/page", {
    title => "$nom Title",
    description => "Description of " . lc($nom) . " page",
  }, "create $nom page");

  my $page_uuid = $json->{id};
  ok $page_uuid, "JSON has page uuid";
  is $json->{title}, "$nom Title", "Right value for title";
  is $json->{description}, "Description of ".lc($nom)." page", "Right value for description";

  $pages{$nom} = $page_uuid;

}

$json = GET_ok("/project/$uuid/page", "Get list of pages");

ok $json->{_embedded}, "JSON has pages property";
is scalar(@{$json->{_embedded}}), 4, "Four pages in project";

#
# Then create a sitemap with the pages
#

# $pages{'Bar'} has slug 'about' and parent ''
# $pages{'Baz'} has slug 'projects' and parent ''
# $pages{'Foo'} has slug '' and no parent

PUT_ok("/page/$pages{'Bar'}", {
  parent_page => $pages{'Foo'},
  slug => 'about',
}, "Make Bar a child of Foo");

$json = GET_ok("/page/$pages{'Bar'}", "Get updated Bar page");
is $json->{slug}, "about", "Right slug";

PUT_ok("/page/$pages{'Baz'}", {
  parent_page => $pages{'Foo'},
  slug => 'projects',
}, "Make Baz a child of Foo");

$json = GET_ok("/page/$pages{'Baz'}", "Get updated Baz page");
is $json->{slug}, "projects", "Right slug";

PUT_ok("/page/$pages{'Foo'}", {
  parent_page => undef,
  slug => ''
}, "No parent page for Foo");

$json = GET_ok("/page/$pages{'Foo'}", "Get updated Foo page");
is $json->{slug}, "", "Right slug";

PUT_ok("/project/$uuid", {
  home_page => $pages{'Foo'}
}, "Set root page for project to Foo");

$json = GET_ok("/project/$uuid", "Get update project");

diag JSON::to_json( $json );

ok( !request('/v')->is_success, 'Request should not succeed' );

ok( request("/dev/v/$uuid/") -> is_success, 'Request should succeed' );

ok( !request("/dev/v/$uuid/boo") -> is_success, "/boo isn't in project" );
ok( request("/dev/v/$uuid/about") -> is_success, "/about is in project" );
ok( request("/dev/v/$uuid/projects") -> is_success, "/projects is in project" );
ok( !request("/dev/v/$uuid/projects/ookook") -> is_success, "/projects/ookook isn't in project" );

my $before_date = DateTime->now;
$before_date = $before_date->ymd('').$before_date->hms('');

ok( !request("/$before_date/v/$uuid/")->is_success, "No frozen edition yet");

ok( !request("/v/$uuid/") -> is_success, "No available edition yet");

sleep(2);

POST_ok("/project/$uuid/edition", {}, "Create a frozen edition");

sleep(2);

my $after_date = DateTime->now;
$after_date = $after_date->ymd('').$after_date->hms('');

ok( !request("/$before_date/v/$uuid/")->is_success, "Date preceeds freeze");
ok( request("/$after_date/v/$uuid/")->is_success, "Date is after freeze");

#
# Now see if dev site is still available
#

ok( request("/dev/v/$uuid/about") -> is_success, "About page is still there");

done_testing();
