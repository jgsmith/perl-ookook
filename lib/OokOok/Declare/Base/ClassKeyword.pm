use MooseX::Declare;

# PODNAME: OokOok::Declare::Base::ClassKeyword

# ABSTRACT: Base class for class-type keywords

class OokOok::Declare::Base::ClassKeyword 
  extends MooseX::Declare::Syntax::Keyword::Class
  with CatalystX::Declare::DefaultSuperclassing {

  after add_namespace_customizations (Object $ctx, Str $package) {
    my $code = "use CLASS"; 
    if($self -> import_ookook_symbols_from($ctx)) {
      $code .= 
        sprintf "; use %s qw( %s )", $self -> import_ookook_symbols_from($ctx), join ' ', $self -> imported_ookook_symbols($ctx),
    }
    $ctx -> add_preamble_code_parts( $code );
  }

  method import_ookook_symbols_from (Object $ctx) { ... }

  method imported_ookook_symbols (Object $ctx) { ... }

  method default_superclasses { ... }
}
