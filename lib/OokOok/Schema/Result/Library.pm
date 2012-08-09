use utf8;
package OokOok::Schema::Result::Library;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::Library

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<library>

=cut

__PACKAGE__->table("library");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 uuid

  data_type: 'char'
  is_nullable: 0
  size: 20

=head2 new_project_prefix

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 new_theme_prefix

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 board_id

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "uuid",
  { data_type => "char", is_nullable => 0, size => 20 },
  "new_project_prefix",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "new_theme_prefix",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "board_id",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-07-29 17:28:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:W49yrKVZInXDNwdAS3UMlw

__PACKAGE__->has_many(
  "editions" => 'OokOok::Schema::Result::LibraryEdition',
  'library_id'
);

__PACKAGE__ -> belongs_to( board => 'OokOok::Schema::Result::Board', 'board_id' );

with 'OokOok::Role::Schema::Result::HasEditions';

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
