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

is scalar($project_rs -> all), 0, "No projects loaded";
is scalar($edition_rs -> all), 0, "No editions loaded";

my $project = $project_rs -> create({
  user_id => 1
});

is scalar($project_rs -> all), 1, "One project";
is scalar($edition_rs -> all), 1, "One edition";

ok $project-uuid, "Project has a uuid";

my $instance = $project -> current_edition;

ok !$instance -> is_frozen, "Not frozen";

$instance -> freeze;

ok $instance -> is_frozen, "Now frozen";

is scalar($edition_rs -> all), 2, "Two editions";

isnt $project->current_edition->id, $instance->id, "Different edition";

$instance = $project->current_edition;

ok !$instance -> is_frozen, "Newest edition is not frozen";
