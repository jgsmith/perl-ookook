use MooseX::Declare;

# PODNAME: OokOok::Declare::Keyword::TagLibrary

# ABSTRACT: Implementation for taglib keyword

=head1 SYNOPSIS

 use OokOok::Declare;

 taglib OokOok::Template::TagLibrary::Foo {
   attribute bat isa Str; # makes @bat available on any element that is a
                          # taglib element - way to set something on a
                          # somewhat global level

   element bar (Str :$baz) {
     # we have $ctx => OokOok::Template::Context
     #         $self => taglib class instance
     #         $baz => attribute baz from namespace
   }
 }

=cut

class OokOok::Declare::Keyword::TagLibrary
  extends MooseX::Declare::Syntax::Keyword::Class
  with CatalystX::Declare::DefaultSuperclassing {

  use aliased 'OokOok::Declare::Keyword::Element' => 'ElementKeyword';

  around default_inner {
    return [
      ElementKeyword -> new( identifier => 'element' ),
      #AttributeKeyword -> new( identifier => 'attribute' ),
    ];
  }

  method default_superclasses { 'OokOok::Declare::Base::TagLibrary' }
}

=head1 SEE ALSO

=for :list
* L<OokOok::Declare::Symbols::TagLibrary>

=cut
