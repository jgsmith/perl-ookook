use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::LibraryProjectVersion

# ABSTRACT: temporal data about how a project uses a library

table_version OokOok::Schema::Result::LibraryProjectVersion {

  prop library_date => (
    data_type => 'datetime',
    is_nullable => 0,
  );

  prop prefix => (
    data_type => 'varchar',
    is_nullable => 1,
    size => 32,
  );

}
