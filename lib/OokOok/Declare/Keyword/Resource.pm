use MooseX::Declare;

# PODNAME: OokOok::Declare::Keyword::Resource

# ABSTRACT: provides keyword for declaring REST resources

=head1 SYNOPSIS

 use OokOok::Declare;

 resource OokOok::Resource::Thing {
   prop id => (
     is => 'ro',
     source => sub { $_[0] -> source -> uuid },
   );
 
   belongs_to stuff => 'OokOok::Resource::Stuff', (
     is => 'ro',
     required => 1,
   );
 
   has_many doodads => 'OokOok::Resource::Doodad', (
     is => 'ro',
   );
 
   method can_GET { ... }
   method can_PUT { ... }
   method can_DELETE { ... }
 }

=head1 DESCRIPTION

The C<resource> keyword sets up certain defaults to tie the resource
class into the OokOok database schema. The following two snippets are
essentially equivalent:

 resource OokOok::Resource::Thing {
 }

and

 package OokOok::Resource::Thing;
 use Moose;
 extends OokOok::Declare::Base::Resource;

 use OokOok::Declare::Symbols::Resource;
 
 has '+source' => ( isa => 'OokOok::Model::DB::Thing' );

=cut

class OokOok::Declare::Keyword::Resource
  extends MooseX::Declare::Syntax::Keyword::Class 
  with CatalystX::Declare::DefaultSuperclassing {

  after add_namespace_customizations (Object $ctx, Str $package) {
    $ctx -> add_preamble_code_parts(
      sprintf 'use %s qw( %s )', $self -> import_ookook_symbols_from($ctx), join ' ', $self -> imported_ookook_symbols($ctx),
    );

    #my $model = $package;
    #$model =~ s{^.*::}{OokOok::Model::DB::};
    #$ctx -> add_preamble_code_parts(
    #  sprintf q{has '+source' => ( isa => '%s' );}, $model
    #);
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

=head1 SEE ALSO

=for :list
* L<OokOok::Declare::Symbols::Resource>

=cut
