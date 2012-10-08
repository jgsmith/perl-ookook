use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::ThemeAssetVersion;

# ABSTRACT: Versions of a theme asset

table_version OokOok::Schema::Result::ThemeAssetVersion {

  is_publishable;

  prop size => (
    data_type => 'integer',
    is_nullable => 1,
  );

  #prop filename => (
  #  data_type => 'varchar',
  #  is_nullable => 0,
  #  size => 255,
  #  unique => 1,
  #);

  prop name => (
    data_type => 'varchar',
    is_nullable => 1,
    size => 255,
  );

  prop mime_type => (
    data_type => 'varchar',
    is_nullable => 1,
    size => 64,
  );

  prop type => (
    data_type => 'varchar',
    is_nullable => 1,
    size => 64,
  );

  prop width => (
    data_type => 'integer',
    is_nullable => 1,
  );

  prop height => (
    data_type => 'integer',
    is_nullable => 1,
  );

  # hook into MongoDB
  prop file_id => (
    data_type => 'varchar',
    is_nullable => 1,
    size => 255,
  );

  override duplicate_to_current_edition(Object $previous?) {
    my $new = super;
    $new -> update({ file_id => undef });
    $new;
  }
}
