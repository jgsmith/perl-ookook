use utf8;
package OokOok::Schema::Result::BoardMemberApplicant;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::BoardMemberApplicant

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

=head1 TABLE: C<board_member_applicant>

=cut

__PACKAGE__->table("board_member_applicant");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 board_member_id

  data_type: 'integer'
  is_nullable: 0

=head2 board_applicant_id

  data_type: 'integer'
  is_nullable: 0

=head2 vote

  data_type: 'integer'
  is_nullable: 1

=head2 comments

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "board_member_id",
  { data_type => "integer", is_nullable => 0 },
  "board_applicant_id",
  { data_type => "integer", is_nullable => 0 },
  "vote",
  { data_type => "integer", is_nullable => 1 },
  "comments",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-08-09 11:53:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yC0UB+dPsMIjXQkDHrQalA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
