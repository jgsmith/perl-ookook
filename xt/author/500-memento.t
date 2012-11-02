use strict;
use warnings;
use Test::More;
use HTTP::Request::Common;
use JSON;

BEGIN {
  $ENV{'OOKOOK_CONFIG_LOCAL_SUFFIX'} = "testing";
}

use OokOok::ForTesting::REST;
use OokOok::Controller::WellKnown;

my $meta = get("/.well-known/host-meta");

my $timegate_rel = qr{rel=['"]timegate['"]};
my $timegate_tmpl = qr{template=['"][^"']*?/timegate/{path}["']};
my $timemap_rel = qr{rel=['"]timemap['"]};
my $timemap_tmpl = qr{template=['"][^'"]*?/timemap/{path}['"]};
my $timegate_qr = qr{($timegate_rel\s+$timegate_tmpl)|($timegate_tmpl\s+$timegate_rel)};
my $timemap_qr = qr{($timemap_rel\s+$timemap_tmpl)|($timemap_tmpl\s+$timemap_rel)};

# host-meta must have a timegate link and a timemap link

like( $meta, $timegate_qr, "Timegate link in host-meta" );
like( $meta, $timemap_qr, "Timemap link in host-meta" );

# set things up so we can get some timemap/timegate content going


my $json;

#
# Create an empty theme
#

$json = POST_ok("/theme", {
    name => 'Test Theme',
  }, "Create theme");

my $theme_uuid = $json -> {id};
ok $theme_uuid, "We have a theme uuid";

POST_ok("/theme/$theme_uuid/edition", {}, "Publish theme");
my $theme_date = DateTime->now->iso8601;

#
# Create project and populate with sitemap
#

my $project_uuid;

$json = POST_ok("/project", {
  name => "Test Project",
  description => "Test project description",
  theme => $theme_uuid,
  theme_date => $theme_date,
}, "create project");

$project_uuid = $json -> {id};
ok $project_uuid, "We have a project uuid";

my %pages;

for my $nom (qw/Foo Bar Baz/) {

  $json = POST_ok("/project/$project_uuid/page", {
    title => "$nom Title",
    description => "Description of " . lc($nom) . " page",
    status => 0,
  }, "create $nom page");

  my $page_uuid = $json->{id};
  ok $page_uuid, "JSON has page uuid";

  $pages{$nom} = $page_uuid;
}


PUT_ok("/project/$project_uuid", {
  home_page => $pages{Foo},
}, "Set root page for project to Foo");

PUT_ok("/page/$pages{Foo}", {
  status => 0,
});

PUT_ok("/page/$pages{Bar}", {
  parent_page => $pages{Foo},
  status => 0,
  slug => 'bar',
});

PUT_ok("/page/$pages{Baz}", {
  parent_page => $pages{Bar},
  status => 0,
  slug => 'baz',
});

POST_ok("/project/$project_uuid/edition", {}, "Create project edition");

$meta = get("/timemap/v/$project_uuid/");

diag $meta;

$meta = get("/timemap/v/$project_uuid/bar");

diag $meta;

$meta = get("/timemap/v/$project_uuid/bar/baz");

diag $meta;

done_testing();
