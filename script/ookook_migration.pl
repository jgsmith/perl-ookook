#!/usr/bin/env perl

use lib './lib';

use OokOok;
use DBIx::Class::Migration::Script;

DBIx::Class::Migration::Script -> run_with_options(
  schema => OokOok->model('DB')->schema,
  databases => ['PostgreSQL'],
);
