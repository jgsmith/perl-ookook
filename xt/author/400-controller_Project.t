use strict;
use warnings;
use Test::More;
use HTTP::Request::Common;
use JSON;

BEGIN {
  $ENV{'OOKOOK_CONFIG_LOCAL_SUFFIX'} = "testing";
}

use OokOok::ForTesting::REST;

#
# Get an empty listing of projects
#

my $json;

$json = GET_ok("/project", "JSON listing of projects");

is_deeply $json->{_embedded}, [], "Empty list of projects";

#
# Create an empty theme
#

$json = POST_ok("/theme", {
    name => 'Test Theme',
  }, "Create theme");

my $theme_uuid = $json -> {id};
ok $theme_uuid, "We have a theme uuid";
my $theme_date = DateTime->now;

#
# Create a project
#

$json = POST_ok("/project", {
    name => "Test Project",
    description => "Test project description",
    theme => $theme_uuid,
    theme_date => $theme_date -> iso8601,
  }, "create project");

is $json->{name}, "Test Project", "Name returned";
is $json->{description}, "Test project description", "Description returned";
ok $json->{id}, "Project has a uuid";

my $uuid = $json->{id};

#
# Get the newly created project
#
$json = GET_ok("/project/$uuid", "Get new project");

is $json->{name}, "Test Project", "Right name returned";
is $json->{description}, "Test project description", "Right description returned";
is $json->{id}, $uuid, "Right uuid returned";

#
# See if list of projects has one member
#

$json = GET_ok("/project", "JSON listing of projects");
#diag JSON::encode_json($json);

ok $json->{_embedded}, "Projects key exists in returned JSON";
is scalar(@{$json->{_embedded}}), 1, "One project";
is $json->{_embedded}->[0]->{id}, $uuid, "Right project";

#
# Now see if we can delete the project
#

DELETE_ok("/project/$uuid", "delete project");

#
# We shouldn't be able to get the project now
#
GET_not_ok("/project/$uuid", "get deleted project");

#
# Now we should have no projects again
#

$json = GET_ok("/project", "JSON listing of projects");

ok $json->{_embedded}, "Projects key exists in returned JSON";
is scalar(@{$json->{_embedded}}), 0, "No projects";

#
# Add another project
#

$json = POST_ok("/project", {
  name => "Test Project 2",
  description => "Another test project",
  theme => $theme_uuid,
  theme_date => $theme_date -> iso8601,
}, "create another project");

is $json->{name}, "Test Project 2", "Right name";
is $json->{description}, "Another test project", "Right description";

$uuid = $json -> {id};

#
# Get the project
#

$json = GET_ok("/project/$uuid", "Get the project");

is $json->{id}, $uuid, "Right uuid";

ok $json->{_embedded} -> {editions}, "JSON has an editions key";
is scalar(@{$json->{_embedded}->{editions}}), 1, "Only one edition";

ok !$json->{_embedded}->{editions}->[0]->{closed_on}, "Edition isn't frozen";

#
# Update project description
#

$json = PUT_ok("/project/$uuid", {
  description => "Second description",
}, "Update project description");

is $json->{id}, $uuid, "Right uuid";
is $json->{description}, "Second description", "Right description";

#
# Make sure project still has no frozen editions
#

$json = GET_ok("/project/$uuid", "Get the project");

is $json->{id}, $uuid, "Right uuid";
is $json->{description}, "Second description", "Right description";

ok $json->{_embedded}->{editions}, "JSON has a project.editions key";
is scalar(@{$json->{_embedded}->{editions}}), 1, "Only one edition";

ok !$json->{_embedded}->{editions}->[0]->{closed_on}, "Edition isn't frozen";

#
# Make sure project still has no frozen editions
#

$json = GET_ok("/project/$uuid", "Get the project");

is $json->{id}, $uuid, "Right uuid";
is $json->{description}, "Second description", "Right description";

ok $json->{_embedded} -> {editions}, "JSON has a project.editions key";
is scalar(@{$json->{_embedded} -> {editions}}), 1, "Only one edition";

ok !$json->{_embedded} -> {editions}->[0]->{closed_on}, "Edition isn't frozen";

#
# Now we need to add a few pages to the project
#

$json = GET_ok("/project/$uuid/page", "Get list of pages");

ok $json->{_embedded}, "JSON has pages property";
is scalar(@{$json->{_embedded}}), 1, "One page in project";

$json = POST_ok("/project/$uuid/page", {
  title => "Page Title",
  description => "Description of page",
}, "create page");

my $page_uuid = $json->{id};
ok $page_uuid, "JSON has page uuid";
is $json->{title}, "Page Title", "Right value for title";
is $json->{description}, "Description of page", "Right value for description";

$json = GET_ok("/project/$uuid/page", "Get list of pages");

ok $json->{_embedded}, "JSON has pages property";
is scalar(@{$json->{_embedded}}), 2, "Two pages in project";

$json = GET_ok("/page/$page_uuid", "Get page info");

is $json->{id}, $page_uuid, "Right uuid";
is $json->{title}, "Page Title", "Right value for title";
is $json->{description}, "Description of page", "Right value for description";

#
# Now we freeze the edition
#

sleep(1);

$json = POST_ok("/project/$uuid/edition", {}, "create new working edition");

ok $json->{created_on}, "JSON has created on date";

$json = POST_ok("/project/$uuid/page", {
  title => "Second page title",
  description => "Description of another page",
}, "Create a new page");

my $page2_uuid = $json -> {id};

isnt $page2_uuid, $page_uuid, "Two pages are two uuids";

$json = GET_ok("/project/$uuid/page", "Get list of pages");

is scalar(@{$json->{_embedded}}), 3, "Three pages in project";

$json = DELETE_ok("/project/$uuid/edition", "Clear working edition");

$json = GET_ok("/project/$uuid/page", "Get list of pages");

is scalar(@{$json->{_embedded}}), 2, "Two pages in project after clearing working edition";

done_testing();
