use MooseX::Declare;

# PODNAME: OokOok::Declare::Base::ClassKeyword

class OokOok::Declare::Base::ClassKeyword 
  extends MooseX::Declare::Syntax::Keyword::Class
  with CatalystX::Declare::DefaultSuperclassing {

  after add_namespace_customizations (Object $ctx, Str $package) {
    $ctx -> add_preamble_code_parts( 'use CLASS;' );
    $ctx -> add_preamble_code_parts(
      sprintf 'use %s qw( %s )', $self -> import_ookook_symbols_from($ctx), join ' ', $self -> imported_ookook_symbols($ctx),
    ) if $self -> import_ookook_symbols_from($ctx);
  }

  method import_ookook_symbols_from (Object $ctx) { ... }

  method imported_ookook_symbols (Object $ctx) { ... }

  method default_superclasses { ... }
}
