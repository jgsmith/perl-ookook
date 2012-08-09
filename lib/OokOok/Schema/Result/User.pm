use utf8;
package OokOok::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::User

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

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 uuid

  data_type: 'char'
  is_nullable: 0
  size: 20

=head2 lang

  data_type: 'varchar'
  is_nullable: 1
  size: 8

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 is_admin

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 timezone

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 description

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "uuid",
  { data_type => "char", is_nullable => 0, size => 20 },
  "lang",
  { data_type => "varchar", is_nullable => 1, size => 8 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "is_admin",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "timezone",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "description",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-07-31 19:12:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:J1KY2oAgrGgn+fgSxm8idA

with 'OokOok::Role::Schema::Result::UUID';

__PACKAGE__ -> has_many( oauth_identities => 'OokOok::Schema::Result::OauthIdentity', 'user_id' );

__PACKAGE__ -> has_many( board_members => 'OokOok::Schema::Result::BoardMember', 'user_id' );
__PACKAGE__ -> has_many( board_applicants => 'OokOok::Schema::Result::BoardApplicant', 'user_id' );

__PACKAGE__ -> many_to_many( board_ranks => 'board_members', 'board_rank' );

__PACKAGE__ -> has_many( emails => 'OokOok::Schema::Result::Email', 'user_id' );

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
