use utf8;
package OokOok::Schema::Result::BoardMember;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::BoardMember

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

=head1 TABLE: C<board_member>

=cut

__PACKAGE__->table("board_member");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_nullable: 0

=head2 board_id

  data_type: 'integer'
  is_nullable: 0

=head2 rank

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_nullable => 0 },
  "board_id",
  { data_type => "integer", is_nullable => 0 },
  "rank",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-08-04 15:18:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:39f31dBqJPozZrger99rwA

__PACKAGE__ -> belongs_to( user => 'OokOok::Schema::Result::User', 'user_id' );
__PACKAGE__ -> belongs_to( board => 'OokOok::Schema::Result::Board', 'board_id' );

sub board_rank {
  $_[0] -> board -> board_ranks -> find({ position => $_[0] -> rank });
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
