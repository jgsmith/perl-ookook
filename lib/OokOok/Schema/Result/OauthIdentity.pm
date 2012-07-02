use utf8;
package OokOok::Schema::Result::OauthIdentity;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::OauthIdentity

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

=head1 TABLE: C<oauth_identity>

=cut

__PACKAGE__->table("oauth_identity");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_nullable: 0

=head2 oauth_service_id

  data_type: 'integer'
  is_nullable: 1

=head2 oauth_user_id

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 screen_name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 token

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 token_secret

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 profile_img_url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_nullable => 0 },
  "oauth_service_id",
  { data_type => "integer", is_nullable => 1 },
  "oauth_user_id",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "screen_name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "token",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "token_secret",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "profile_img_url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-07-01 11:44:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LOe3I2T10AZiPpk3hlDN2Q

__PACKAGE__ -> belongs_to( user => 'OokOok::Schema::Result::User', 'user_id' );

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
