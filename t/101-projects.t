#!/usr/bin/env perl

use DBIx::Class::Fixtures;
use Test::More no_plan;
#use lib 't/lib';

BEGIN { 
  use_ok "OokOok::Model::DB";
  use_ok "OokOok::Schema";
}


my $schema = OokOok::Schema -> connect('dbi:SQLite:dbname=:memory:');
ok $schema, "Schema object loads";

#
# Project
#

my $project_rs = $schema -> resultset("Project");
my $edition_rs = $schema -> resultset("Edition");
my $page_rs = $schema -> resultset("Page");
my $page_version_rs = $schema -> resultset("PageVersion");

is $project_rs -> count, 0, "No projects loaded";
is $edition_rs -> count, 0, "No editions loaded";
is $page_rs -> count, 0, "No pages loaded";
is $page_version_rs -> count, 0, "No page versions loaded";

my $project = $project_rs -> create({
});

is $project_rs -> count, 1, "One project";
is $edition_rs -> count, 1, "One edition";
is $page_rs -> count, 1, "One page";
is $page_version_rs -> count, 1, "One page version";

ok $project-uuid, "Project has a uuid";

my $instance = $project -> current_edition;

ok !$instance -> is_closed, "Not frozen";

$instance -> close;

ok $instance -> is_closed, "Now frozen";

is $edition_rs -> count, 2, "Two editions";

isnt $project->current_edition->id, $instance->id, "Different edition";

$instance = $project->current_edition;

ok !$instance -> is_closed, "Newest edition is not frozen";
