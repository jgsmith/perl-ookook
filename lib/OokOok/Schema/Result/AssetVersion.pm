use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::AssetVersion

# ABSTRACT: Project Asset version

table_version OokOok::Schema::Result::AssetVersion {

  is_publishable;

  prop size => (
    data_type => 'integer',
    is_nullable => 1,
  );

  prop filename => (
    data_type => 'char',
    is_nullable => 1,
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

  # We may get rid of this eventually and hold the metadata in a
  # triple-store database so that only the blob-related stuff is here
  prop metadata => (
    data_type => 'text',
    is_nullable => 1,
  );

}
