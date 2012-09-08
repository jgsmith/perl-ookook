use MooseX::Declare;

class OokOok::Declare::Keyword::Resource
  extends MooseX::Declare::Syntax::Keyword::Class 
  with CatalystX::Declare::DefaultSuperclassing {

  after add_namespace_customizations (Object $ctx, Str $package) {
    $ctx -> add_preamble_code_parts(
      sprintf 'use %s qw( %s )', $self -> import_ookook_symbols_from($ctx), join ' ', $self -> imported_ookook_symbols($ctx),
    );
  }

  method import_ookook_symbols_from (Object $ctx) {
    'OokOok::Declare::Symbols::Resource'
  }

  method imported_ookook_symbols (Object $ctx) {
    qw[
      prop has_many belongs_to collection_class has_a resource_name
    ];
  }

  method default_superclasses { 'OokOok::Declare::Base::Resource' }
}
