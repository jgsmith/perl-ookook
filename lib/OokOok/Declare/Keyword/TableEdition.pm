
# PODNAME: OokOok::Declare::Keyword::TableEdition

class OokOok::Declare::Keyword::TableEdition
  extends OokOok::Declare::Base::ClassKeyword {

  method import_ookook_symbols_from (Object $ctx) {
    'OokOok::Declare::Symbols::TableEdition'
  }

  method imported_ookook_symbols (Object $ctx) {
    qw[
      prop owns_many references references_own
    ]
  }

  method default_superclasses { 'OokOok::Declare::Base::TableEdition' }

  around auto_make_immutable { 0 }
}
