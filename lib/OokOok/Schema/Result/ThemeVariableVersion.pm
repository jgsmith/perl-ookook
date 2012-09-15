use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::ThemeVariableVersion

table_version OokOok::Schema::Result::ThemeVariableVersion {

  is_publishable;

  prop unused => (
    data_type => 'boolean',
    default_value => 0,
    is_nullable => 0,
  );

  prop name => (
    data_type => 'varchar',
    is_nullable => 0,
    default_value => '',
    size => 255,
  );

  prop type => (
    data_type => 'varchar',
    default_value => 'text',
    is_nullable => 0,
    size => 255,
  );

}
