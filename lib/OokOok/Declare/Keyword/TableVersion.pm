
# PODNAME: OokOok::Declare::Keyword::TableVersion

class OokOok::Declare::Keyword::TableVersion
  extends OokOok::Declare::Base::ClassKeyword {

  method import_ookook_symbols_from (Object $ctx) {
    'OokOok::Declare::Symbols::TableVersion'
  }

  method imported_ookook_symbols (Object $ctx) {
    qw[
      prop owns_many is_publishable
    ]
  }

  method default_superclasses { 'OokOok::Declare::Base::TableVersion' }

  around auto_make_immutable { 0 }
}
