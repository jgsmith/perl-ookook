use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::TypefaceFontFile

Table OokOok::Schema::Result::TypefaceFontFile {

  prop filename => (
    data_type => 'char',
    is_nullable => 0,
    size => 20,
    unique => 1,
  );

  prop format => (
    data_type => 'varchar',
    is_nullable => 0,
    size => 16,
  );

}
