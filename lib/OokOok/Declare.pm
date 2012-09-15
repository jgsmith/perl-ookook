use MooseX::Declare;
use 5.008008;

# PODNAME: OokOok::Declare

# ABSTRACT: Declarative Syntax for OokOok Components

class OokOok::Declare extends CatalystX::Declare is dirty is mutable {

  use aliased 'OokOok::Declare::Keyword::TagLibrary',     'TagLibraryKeyword';
  use aliased 'OokOok::Declare::Keyword::RESTController', 'RESTControllerKeyword';
  use aliased 'OokOok::Declare::Keyword::PlayController', 'PlayControllerKeyword';
  use aliased 'OokOok::Declare::Keyword::AdminController', 'AdminControllerKeyword';
  use aliased 'OokOok::Declare::Keyword::Resource',       'ResourceKeyword';
  use aliased 'OokOok::Declare::Keyword::Collection',     'CollectionKeyword';
  use aliased 'OokOok::Declare::Keyword::Table',          'TableKeyword';
  use aliased 'OokOok::Declare::Keyword::EditionedTable', 'EditionedTableKeyword';
  use aliased 'OokOok::Declare::Keyword::VersionedTable', 'VersionedTableKeyword';
  use aliased 'OokOok::Declare::Keyword::TableEdition', 'TableEditionKeyword';
  use aliased 'OokOok::Declare::Keyword::TableVersion', 'TableVersionKeyword';

  clean;

  around keywords (ClassName|Object $self:) {
    $self->$orig,

    RESTControllerKeyword->new( identifier => 'rest_controller' ),
    PlayControllerKeyword->new( identifier => 'play_controller' ),
    AdminControllerKeyword->new( identifier => 'admin_controller' ),
    ResourceKeyword->new(       identifier => 'resource' ),
    TagLibraryKeyword->new(     identifier => 'taglib' ),
    CollectionKeyword->new(     identifier => 'collection' ),
    TableKeyword->new(          identifier => 'Table' ),
    EditionedTableKeyword->new( identifier => 'editioned_table' ),
    VersionedTableKeyword->new( identifier => 'versioned_table' ),
    TableEditionKeyword->new(   identifier => 'table_edition'   ),
    TableVersionKeyword->new(   identifier => 'table_version'   ),
  }
}

=head1 SYNOPSIS

=head2 REST Controller

 use OokOok::Declare;

 rest_controller OokOok::Controller::Thing {
   under resource_base {
     # stuff here will be under '/thing/$uuid/'
   }
 }

=head2 Play Controller

 use OokOok::Declare;

 play_controller OokOok::Controller::Thing {
   under '/' {
     action base as 't' {
       $ctx -> stash -> {collection} = OokOok::Collection::Thing -> new(
         c => $ctx,
       );
     }
   }

   under play_base {
     final action play (@path) as '' isa REST {
       # do stuff to 'play' things
     }
   }
 }

=head2 Admin Controller

 use OokOok::Declare;

 admin_controller OokOok::Controller::Admin::Thing {
   ...
 }

=head2 Resource

 use OokOok::Declare;

 resource OokOok::Resource::Thing {
   ...
 }

=head2 Tag Library

 use OokOok::Declare;

 taglib OokOok::TagLibrary::Foo {
   element foo (...) { ... }
 }

=head1 DESCRIPTION

This module provides a declarative syntax for OokOok components. Its main
focus is currently on common and repeitious parts of the application, such
as types of controllers, REST resources, and schema result classes.

=head2 Syntax Documentation

The documentation about syntax is in the respective parts of the distribution
below the C<OokOok::Declare::Keyword::> namespace. Here are the manual pages
you will be interested in to familiarize yourself with this module's syntax
extensions:

L<OokOok::Declare::Keyword::RESTController>
L<OokOok::Declare::Keyword::PlayController>
L<OokOok::Declare::Keyword::AdminController>
L<OokOok::Declare::Keyword::Resource>
L<OokOok::Declare::Keyword::TagLibrary>
L<OokOok::Declare::Keyword::Table>
L<OokOok::Declare::Keyword::VersionedTable>
L<OokOok::Declare::Keyword::EditionedTable>
L<OokOok::Declare::Keyword::TableVersion>
L<OokOok::Declare::Keyword::TableEdition>

=head1 SEE ALSO

=for :list
* L<CatalystX::Declare>
We inherit all of the functionality from L<CatalystX::Declare>, which
in-turn inherits almost all of the functionality of L<MooseX::Declare>.
* L<MooseX::Declare>
* L<MooseX::Method::Signatures>
