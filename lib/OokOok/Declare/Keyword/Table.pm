
# PODNAME: OokOok::Declare::Keyword::Table

class OokOok::Declare::Keyword::Table
  extends OokOok::Declare::Base::ClassKeyword {

  method import_ookook_symbols_from (Object $ctx) {
    'OokOok::Declare::Symbols::Table'
  }

  method imported_ookook_symbols (Object $ctx) {
    qw[
      prop owns_many with_uuid references
    ]
  }

  method default_superclasses { 'OokOok::Declare::Base::Table' }

  around auto_make_immutable { 0 }
}
