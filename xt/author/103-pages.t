#!/usr/bin/env perl

use DBIx::Class::Fixtures;
use Test::More no_plan;

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

my $project_rs = $schema -> resultset("Project");
my $edition_rs = $schema -> resultset("Edition");
my $page_rs = $schema -> resultset("Page");
my $page_version_rs = $schema -> resultset("PageVersion");
my $page_part_rs = $schema -> resultset("PagePart");

my $project = $project_rs ->  create({
});

my $instance = $project -> current_edition;

#
# Add some pages
#

# We shouldn't have any pages in the DB when we start.
is $page_rs->count, 1, "One page in the DB";

# We create a page in the current edition.
my $page = $project -> create_related('pages', {});
is $page_rs->count, 2, "Only two pages in the DB after creating page";
is $page_version_rs->count, 2, "Only two page versions";

$page -> current_version -> update({
  title => "Test Page"
});

# Now we should have a single page in the DB.
is $page_rs->count, 2, "Only two pages in the DB after updating page";
is $page_version_rs->count, 2, "Only two page versions";

# And it should have an auto-generated uuid.
ok $page->uuid, "Page has uuid";

my $uuid = $page->uuid;

# We still have only one page in the DB. This test and those like it
# for the next few tests are because of a bug that was making two pages
# appear for some reason and it wasn't obvious which operation was causing
# the problem.
is $page_rs->count, 2, "Only two pages in the DB after testing uuid";
is $page_version_rs->count, 2, "Only two page versions in the DB after testing uuid";

# Now we get the page that should be shown for the current un-frozen
# "working" edition.
my $qp = $project -> page($uuid);

# Since we only have one page in the database, and the only edition
# is the working edition, we should get the same page as we created
# above.
is $qp->id, $page->id, "We get the right page through the project";

my $pv = $page -> current_version();
my $qpv = $page -> version_for_date();

is $qpv->id, $pv->id, "We get the same page version through current_version/version_for_date";

# Now we can close the working edition. This will mark the edition
# as frozen and create a new working edition for the project.
$instance -> close;

# The working edition should be differant than the one we just froze.
my $next_instance = $project -> current_edition;

isnt $next_instance->id, $instance->id, "Two different editions";

# We should still have a single page in the DB.
is $page_rs->count, 2, "Only two pages in the DB after freezing";

# And it should be the page for the working edition, even if it is
# attached to the now-frozen prior working edition.
$qp = $project -> page($uuid);

is $qp->id, $page->id, "We get the right page through the project after closing";

my $current_version = $page -> current_version;

# Now we update the page.
my $next_version = $current_version -> update({
  title => "Test Page 2"
});

# This should result in two page objects in the DB.
is $page_rs->count, 2, "two pages in the DB after updating page";
is $page_version_rs->count, 3, "three page versions in the DB after updating page";

# And the page we get back from the update should be a different row in the DB
# than the page we tried to update.
isnt $next_version->id, $current_version->id, "Two different page version rows";

# The original page should be unchanged since it's part of a frozen edition.
is $current_version->title, "Test Page", "First page unchanged";
is $next_version->title, "Test Page 2", "Second copy with right title";
is $current_version -> page->uuid, $next_version -> page->uuid, "Shared uuid";

# However, the page we see as part of the working edition is the new one
# that was created when we updated the old one.
$qp = $project -> page($uuid) -> current_version;

is $qp->id, $next_version -> id, "We get the right page version through the project after updating page";

# Now we can find the page appropriate for the project at the time the
# prior working edition was frozen.
$qp = $project -> page($uuid) -> version_for_date($instance -> closed_on);

# This should be the original page and not the updated one.
is $qp->id, $current_version->id, "We get the frozen version when given a date";

# Now if we try to modify $page, we should get an error since there's already
# a page in the working edition with the same uuid.
eval {
  $current_version->update({
    title => "Test Page 3"
  });
};

ok $@, "We get an error when we try to modify an old copy of a page that already has a version in the current edition";

# Since it was an error, the datbase should be unchanged.
is $page_rs->count, 2, "two pages in the DB after updating page version";
is $page_version_rs->count, 3, "three page versions in the DB after updating page version";

# And neither page object was modified by the failed update.
is $current_version->title, "Test Page", "First page unchanged";
is $next_version->title, "Test Page 2", "Second copy with right title";

#
# Page Deletion
#

# Deleting a page from a frozen edition should be an error. We don't want
# a frozen edition to be updated.
eval {
  $page->delete;
};

ok !$@, "We don't get an error when we try to delete a page associated with a frozen edition - we just clear any changes since the freeze";

is $page_rs->count, 2, "two pages in the DB after clearing page";
is $page_version_rs -> count, 2, "two page revisions after clearing page";

# However, we should be able to delete the page version associated with the
# working copy. This will revert the project to the page from the prior
# working edition.
eval {
  $next_version->delete;
};

diag $@ if $@;

ok !$@, "We don't get an error when we try to delete a page associated with the current unfrozen edition";

# Since the delete should work, we expect a single page in the DB.
is $page_rs->count, 2, "two page in the DB after deleting page";
is $page_version_rs->count, 2, "two page versions in the DB after deleting page";


$qp = $project -> page($uuid) -> current_version;

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

my $part = $page -> current_version -> create_related('page_parts', {
  name => "foo"
});

ok !$part->page_version->edition->is_closed, "Page part is associated with a page in an unfrozen edition";

isnt $part->page_version->id, $current_version->id, "The page part is not associated with the original page associated with the frozen edition";
