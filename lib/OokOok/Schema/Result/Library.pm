use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::Library

# ABSTRACT: a library

editioned_table OokOok::Schema::Result::Library {

  prop new_project_prefix => (
    data_type => 'varchar',
    is_nullable => 1,
    size => 32,
  );

  prop new_theme_prefix => (
    data_type => 'varchar',
    is_nullable => 1,
    size => 32,
  );

  has_editions;

}
