use utf8;
package OokOok::Schema::Result::Board;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::Board

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

=head1 TABLE: C<board>

=cut

__PACKAGE__->table("board");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 uuid

  data_type: 'char'
  is_nullable: 1
  size: 20

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 auto_induct

  data_type: 'boolean'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "uuid",
  { data_type => "char", is_nullable => 1, size => 20 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "auto_induct",
  { data_type => "boolean", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-08-09 11:53:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:t8fLx83bewsAGGsRXZBrcw

with 'OokOok::Role::Schema::Result::UUID';

__PACKAGE__ -> has_many(board_ranks => 'OokOok::Schema::Result::BoardRank', 'board_id');
__PACKAGE__ -> has_many(board_members => 'OokOok::Schema::Result::BoardMember', 'board_id');
__PACKAGE__ -> has_many(board_applicants => 'OokOok::Schema::Result::BoardApplicant', 'board_id');

__PACKAGE__ -> has_many(projects => 'OokOok::Schema::Result::Project', 'board_id');

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
