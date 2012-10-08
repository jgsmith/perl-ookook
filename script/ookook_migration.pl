#!/usr/bin/env perl

use lib './lib';

use OokOok;
use DBIx::Class::Migration::Script;

DBIx::Class::Migration::Script -> run_with_options(
  schema => OokOok->model('DB')->schema,
  databases => ['PostgreSQL'],
  dsn => 'DBD:Pg:dbname=ookook_dev',
  dbi_connect_attrs => {
    limit_dialect => 'LimitOffset',
    quote_names   =>       1,
    disable_sth_caching => 1,
    pg_enable_utf8   =>    1,
  }

);
