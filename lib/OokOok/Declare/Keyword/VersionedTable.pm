use MooseX::Declare;

# PODNAME: OokOok::Declare::Keyword::VersionedTable

# ABSTRACT: Provides the versioned_table keyword

class OokOok::Declare::Keyword::VersionedTable
  extends OokOok::Declare::Base::ClassKeyword {

  method import_ookook_symbols_from (Object $ctx) {
    'OokOok::Declare::Symbols::VersionedTable'
  }

  method imported_ookook_symbols (Object $ctx) {
    qw[
      owns_many references
    ]
  }

  method default_superclasses { 'OokOok::Declare::Base::VersionedTable' }

  around auto_make_immutable { 0 }
}
