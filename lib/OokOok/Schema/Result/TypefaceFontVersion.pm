use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::TypefaceFontVersion

# ABSTRACT: a version of a typeface font

table_version OokOok::Schema::Result::TypefaceFontVersion {

  is_publishable;

  prop weight => (
    data_type => 'varchar',
    default_value => 'normal',
    is_nullable => 0,
    size => 32
  );

  prop style => (
    data_type => 'varchar',
    default_value => 'normal',
    is_nullable => 0,
    size => 64
  );

  owns_many typeface_font_files => 'OokOok::Schema::Result::TypefaceFontFile';

}
