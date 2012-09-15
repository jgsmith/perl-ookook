use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::LibraryTheme

# ABSTRACT: a library as used by a theme

versioned_table OokOok::Schema::Result::LibraryTheme {

  references library => 'OokOok::Schema::Result::Library';

}
