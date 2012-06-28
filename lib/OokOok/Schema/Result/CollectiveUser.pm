use utf8;
package OokOok::Schema::Result::CollectiveUser;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::CollectiveUser

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

=head1 TABLE: C<collective_user>

=cut

__PACKAGE__->table("collective_user");

=head1 ACCESSORS

=head2 collective_id

  data_type: 'integer'
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "collective_id",
  { data_type => "integer", is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_nullable => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-06-23 12:06:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vg4jHgeTKPGU4l3YCeIDiw

__PACKAGE__ -> belongs_to( 'group' => 'OokOok::Schema::Result::Collective', 'collective_id' );
__PACKAGE__ -> belongs_to( 'user' => 'OokOok::Schema::Result::User', 'user_id' );

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
