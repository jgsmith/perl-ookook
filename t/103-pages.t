#!/usr/bin/env perl

use DBIx::Class::Fixtures;
use Test::More no_plan;
use lib 't/lib';

BEGIN { 
  use_ok "OokOok::Model::DB";
  use_ok "OokOok::Test::Schema";
}

my $schema = OokOok::Test::Schema -> init;

ok $schema, "Schema object loads";

#
# Project
#

my $project_rs = $schema -> resultset("Project");
my $edition_rs = $schema -> resultset("Edition");
my $page_rs = $schema -> resultset("Page");
my $page_part_rs = $schema -> resultset("PagePart");

my $project = $project_rs ->  create({
  name => "Project One",
  user_id => 1
});

my $instance = $project -> current_edition;

#
# Add some pages
#

is scalar($page_rs->all), 0, "No pages in the DB";

my $page = $instance -> create_related('pages', {
  title => "Test Page"
});

is scalar($page_rs->all), 1, "Only one page in the DB after creating page";

ok $page->uuid, "Page has uuid";

my $uuid = $page->uuid;

is scalar($page_rs->all), 1, "Only one page in the DB after testing uuid";

my $qp = $project -> page_for_date($uuid);

is $qp->id, $page->id, "We get the right page through the project";

$instance -> freeze;

my $next_instance = $project -> current_edition;

isnt $next_instance->id, $instance->id, "Two different editions";

is scalar($page_rs->all), 1, "Only one page in the DB after freezing";

$qp = $project -> page_for_date($uuid);

is $qp->id, $page->id, "We get the right page through the project after freeze";

my $next_page = $page -> update({
  title => "Test Page 2"
});

is scalar($page_rs->all), 2, "two pages in the DB after updating page";

isnt $next_page->id, $page->id, "Two different page rows";

is $page->title, "Test Page", "First page unchanged";
is $next_page->title, "Test Page 2", "Second copy with right title";
is $page->uuid, $next_page->uuid, "Shared uuid";

$qp = $project -> page_for_date($uuid);

is $qp->id, $next_page->id, "We get the right page through the project after updating page";

$qp = $project -> page_for_date($uuid, $instance -> frozen_on);

is $qp->id, $page->id, "We get the frozen version when given a date";

# now if we try to modify $page, we should get an error
eval {
  $page->update({
    title => "Test Page 3"
  });
};

ok $@, "We get an error when we try to modify an old copy of a page that already has a version in the current edition";

is scalar($page_rs->all), 2, "two pages in the DB after updating page";

is $page->title, "Test Page", "First page unchanged";
is $next_page->title, "Test Page 2", "Second copy with right title";

#
# Page Deletion
#

eval {
  $page->delete;
};

ok $@, "We get an error when we try to delete a page associated with a frozen edition";

is scalar($page_rs->all), 2, "two pages in the DB after trying to delete page";

eval {
  $next_page->delete;
};

ok !$@, "We don't get an error when we try to delete a page associated with the current unfrozen edition";
is scalar($page_rs->all), 1, "one page in the DB after deleting page";

$qp = $project -> page_for_date($uuid);

is $qp->id, $page->id, "We get the right page through the project after deleting page";

#
# Page Parts
#

# now that we have only the page associated with the frozen edition, we
# add a page part and make sure the new page part is associated with a
# copy of the page associated with the proto-edition

my $part = $page -> create_related('page_parts', {
  name => "foo"
});

ok !$part->page->edition->is_frozen, "Page part is associated with a page in an unfrozen edition";

isnt $part->page->id, $page->id, "The page part is not associated with the original page associated with the frozen edition";
