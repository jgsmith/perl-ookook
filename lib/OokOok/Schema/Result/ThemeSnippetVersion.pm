use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::ThemeSnippetVersion

# ABSTRACT: a version of a theme snippet

table_version OokOok::Schema::Result::ThemeSnippetVersion {

  is_publishable;

  prop name => (
    data_type => 'varchar',
    default_value => '',
    is_nullable => 0,
    size => 255,
  );

  prop content => (
    data_type => 'text',
    is_nullable => 0,
    default_value => '',
  );

  prop filter => (
    data_type => 'varchar',
    is_nullable => 0,
    default_value => "HTML",
    size => 64,
  );

}
