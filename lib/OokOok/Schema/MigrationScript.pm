package OokOok::Schema::MigrationScript;

use Moose;
use OokOok;

extends 'DBIx::Class::Migration::Script';

sub defaults {
  schema => OokOok->model('DB')->schema,
}

__PACKAGE__->meta->make_immutable;
__PACKAGE__->run_if_script;
