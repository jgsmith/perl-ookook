
# PODNAME: OokOok::Declare::Keyword::EditionedTable

class OokOok::Declare::Keyword::EditionedTable
  extends OokOok::Declare::Base::ClassKeyword {

  method import_ookook_symbols_from (Object $ctx) {
    'OokOok::Declare::Symbols::EditionedTable'
  }

  method imported_ookook_symbols (Object $ctx) {
    qw[
      prop owns_many has_editions
    ]
  }

  method default_superclasses { 'OokOok::Declare::Base::EditionedTable' }

  around auto_make_immutable { 0 }
}
