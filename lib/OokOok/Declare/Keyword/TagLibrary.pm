use MooseX::Declare;

# PODNAME: OokOok::Declare::Keyword::TagLibrary

# ABSTRACT: Implementation for taglib keyword

=head1 SYNOPSIS

 use OokOok::Declare;

 taglib OokOok::TagLibrary::Foo {
   attribute bat isa Str; # makes @bat available on any element that is a
                          # taglib element - way to set something on a
                          # somewhat global level

   documentation <<EOD;
     ...
   EOD

   element bar (Str :$baz) {
     # we have $ctx => OokOok::Template::Context
     #         $self => taglib class instance
     #         $baz => attribute baz from namespace
   }
 }

=cut

class OokOok::Declare::Keyword::TagLibrary
  extends OokOok::Declare::Base::ClassKeyword {

  use aliased 'OokOok::Declare::Keyword::Element' => 'ElementKeyword';

  around default_inner {
    [
      @{$self -> $orig},
      ElementKeyword -> new(  identifier => 'element' ),
      ElementKeyword -> new(  identifier => 'under'   ),
      #AttributeKeyword -> new( identifier => 'attribute' ),
    ];
  }

  method import_ookook_symbols_from (Object $ctx) { 'OokOok::Declare::Symbols::TagLibrary' }

  method imported_ookook_symbols (Object $ctx) { qw(ns documentation) }

  method default_superclasses { 'OokOok::Declare::Base::TagLibrary' }
}

=head1 SEE ALSO

=for :list
* L<OokOok::Declare::Symbols::TagLibrary>

=cut
