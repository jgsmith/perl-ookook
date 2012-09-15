use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::LibraryProject 

# ABSTRACT: A library as used by a project

versioned_table OokOok::Schema::Result::LibraryProject {

  references library => 'OokOok::Schema::Result::Library';

}
