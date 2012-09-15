use MooseX::Declare;

# PODNAME: OokOok::Declare::Keyword::Collection

# ABSTRACT: provides keyword for declaring REST collections

=head1 SYNOPSIS

 use OokOok::Declare;

 collection OokOok::Collection::Thing {
   method can_POST { ... }
 }

=head1 DESCRIPTION

The C<collection> keyword sets up certain defaults to tie the resource
collection class into the OokOok database schema. The following two 
snippets are essentially equivalent:

 collection OokOok::Collection::Thing {
 }

and

 package OokOok::Collection::Thing;
 use Moose;
 extends OokOok::Declare::Base::Collection;

 use OokOok::Declare::Symbols::Collection;
 
=cut

class OokOok::Declare::Keyword::Collection
  extends OokOok::Declare::Base::ClassKeyword {

  method import_ookook_symbols_from (Object $ctx) {
    'OokOok::Declare::Symbols::Collection'
  }

  method imported_ookook_symbols (Object $ctx) {
    qw[
      resource_class resource_model
    ];
  }

  method default_superclasses { 'OokOok::Declare::Base::Collection' }
}

=head1 SEE ALSO

=for :list
* L<OokOok::Declare::Symbols::Collection>

=cut
