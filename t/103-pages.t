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

# We shouldn't have any pages in the DB when we start.
is scalar($page_rs->all), 0, "No pages in the DB";

# We create a page in the current edition.
my $page = $instance -> create_related('pages', {
  title => "Test Page"
});

# Now we should have a single page in the DB.
is scalar($page_rs->all), 1, "Only one page in the DB after creating page";

# And it should have an auto-generated uuid.
ok $page->uuid, "Page has uuid";

my $uuid = $page->uuid;

# We still have only one page in the DB. This test and those like it
# for the next few tests are because of a bug that was making two pages
# appear for some reason and it wasn't obvious which operation was causing
# the problem.
is scalar($page_rs->all), 1, "Only one page in the DB after testing uuid";

# Now we get the page that should be shown for the current un-frozen
# "working" edition.
my $qp = $project -> page_for_date($uuid);

# Since we only have one page in the database, and the only edition
# is the working edition, we should get the same page as we created
# above.
is $qp->id, $page->id, "We get the right page through the project";

# Now we can freeze the working edition. This will mark the edition
# as frozen and create a new working edition for the project.
$instance -> freeze;

# The working edition should be differant than the one we just froze.
my $next_instance = $project -> current_edition;

isnt $next_instance->id, $instance->id, "Two different editions";

# We should still have a single page in the DB.
is scalar($page_rs->all), 1, "Only one page in the DB after freezing";

# And it should be the page for the working edition, even if it is
# attached to the now-frozen prior working edition.
$qp = $project -> page_for_date($uuid);

is $qp->id, $page->id, "We get the right page through the project after freeze";

# Now we update the page.
my $next_page = $page -> update({
  title => "Test Page 2"
});

# This should result in two page objects in the DB.
is scalar($page_rs->all), 2, "two pages in the DB after updating page";

# And the page we get back from the update should be a different row in the DB
# than the page we tried to update.
isnt $next_page->id, $page->id, "Two different page rows";

# The original page should be unchanged since it's part of a frozen edition.
is $page->title, "Test Page", "First page unchanged";
is $next_page->title, "Test Page 2", "Second copy with right title";
is $page->uuid, $next_page->uuid, "Shared uuid";

# However, the page we see as part of the working edition is the new one
# that was created when we updated the old one.
$qp = $project -> page_for_date($uuid);

is $qp->id, $next_page->id, "We get the right page through the project after updating page";

# Now we can find the page appropriate for the project at the time the
# prior working edition was frozen.
$qp = $project -> page_for_date($uuid, $instance -> frozen_on);

# This should be the original page and not the updated one.
is $qp->id, $page->id, "We get the frozen version when given a date";

# Now if we try to modify $page, we should get an error since there's already
# a page in the working edition with the same uuid.
eval {
  $page->update({
    title => "Test Page 3"
  });
};

ok $@, "We get an error when we try to modify an old copy of a page that already has a version in the current edition";

# Since it was an error, the datbase should be unchanged.
is scalar($page_rs->all), 2, "two pages in the DB after updating page";

# And neither page object was modified by the failed update.
is $page->title, "Test Page", "First page unchanged";
is $next_page->title, "Test Page 2", "Second copy with right title";

#
# Page Deletion
#

# Deleting a page from a frozen edition should be an error. We don't want
# a frozen edition to be updated.
eval {
  $page->delete;
};

ok $@, "We get an error when we try to delete a page associated with a frozen edition";

# We should still have two pages in the DB after the failed delete.
is scalar($page_rs->all), 2, "two pages in the DB after trying to delete page";

# However, we should be able to delete the page version associated with the
# working copy. This will revert the project to the page from the prior
# working edition.
eval {
  $next_page->delete;
};

ok !$@, "We don't get an error when we try to delete a page associated with the current unfrozen edition";

# Since the delete should work, we expect a single page in the DB.
is scalar($page_rs->all), 1, "one page in the DB after deleting page";

$qp = $project -> page_for_date($uuid);

# Now the page is the one associated with the prior working edition. Any
# updates to this will result in a new page object being associated with
# the current working edition.
is $qp->id, $page->id, "We get the right page through the project after deleting page";

#
# Page Parts
#

# Now that we have only the page associated with the frozen edition, we
# add a page part and make sure the new page part is associated with a
# copy of the page associated with the working edition.

my $part = $page -> create_related('page_parts', {
  name => "foo"
});

ok !$part->page->edition->is_frozen, "Page part is associated with a page in an unfrozen edition";

isnt $part->page->id, $page->id, "The page part is not associated with the original page associated with the frozen edition";
