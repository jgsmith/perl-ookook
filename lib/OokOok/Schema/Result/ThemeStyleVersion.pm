use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::ThemeStyleVersion

table_version OokOok::Schema::Result::ThemeStyleVersion {

  is_publishable;

  prop name => (
    data_type => 'varchar',
    default_value => '',
    is_nullable => 0,
    size => 255,
  );

  prop styles => (
    data_type => 'text',
    is_nullable => 0,
    default_value => '',
  );

}
