use utf8;
package OokOok::Schema::Result::BoardRank;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::BoardRank

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

=head1 TABLE: C<board_rank>

=cut

__PACKAGE__->table("board_rank");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 board_id

  data_type: 'integer'
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 position

  data_type: 'integer'
  is_nullable: 0

=head2 is_editor

  data_type: 'boolean'
  default_value: FALSE
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "board_id",
  { data_type => "integer", is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "position",
  { data_type => "integer", is_nullable => 0 },
  "is_editor",
  { data_type => "boolean", default_value => \"FALSE", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-07-01 13:25:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:F0lDZnknr6aoPg5gz7aYxw

__PACKAGE__ -> belongs_to( board => 'OokOok::Schema::Result::Board', 'board_id' );

__PACKAGE__ -> has_many( board_members => 'OokOok::Schema::Result::BoardMember', 'board_rank_id' );
__PACKAGE__ -> many_to_many( users => 'board_members', 'user' );

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
