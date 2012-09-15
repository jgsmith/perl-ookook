use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::ThemeAssetVersion;

# ABSTRACT: Versions of a theme asset

table_version OokOok::Schema::Result::ThemeAssetVersion {

  is_publishable;

  prop size => (
    data_type => 'integer',
    is_nullable => 1,
  );

  prop filename => (
    data_type => 'char',
    is_nullable => 0,
    size => 20,
    unique => 1,
  );

  prop name => (
    data_type => 'varchar',
    is_nullable => 0,
    size => 255,
  );

  prop type => (
    data_type => 'varchar',
    is_nullable => 1,
    size => 64,
  );

}
