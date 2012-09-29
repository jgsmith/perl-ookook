use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::LibraryThemeVersion

# ABSTRACT: temporal information about how a theme uses a library

table_version OokOok::Schema::Result::LibraryThemeVersion {

  prop library_date => (
    data_type => 'datetime',
    is_nullable => 0,
  );

  prop prefix => (
    data_type => 'varchar',
    is_nullable => 1,
    size => 32,
  );

  before insert {
    if(!$self -> library_date) {
      $self -> library_date(DateTime->now);
    }
  }

}
