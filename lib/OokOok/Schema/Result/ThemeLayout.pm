use utf8;
package OokOok::Schema::Result::ThemeLayout;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::ThemeLayout

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

=head1 TABLE: C<theme_layout>

=cut

__PACKAGE__->table("theme_layout");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 theme_id

  data_type: 'integer'
  is_nullable: 0

=head2 uuid

  data_type: 'char'
  is_nullable: 0
  size: 20

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "theme_id",
  { data_type => "integer", is_nullable => 0 },
  "uuid",
  { data_type => "char", is_nullable => 0, size => 20 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-06-23 12:03:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aQbDAPCJJWccxy++/dc+BA

with 'OokOok::Role::Schema::Result::HasVersions';

__PACKAGE__ -> belongs_to( theme => 'OokOok::Schema::Result::Theme', 'theme_id' );

sub owner { $_[0] -> theme }

__PACKAGE__ -> has_many( versions => 'OokOok::Schema::Result::ThemeLayoutVersion', 'theme_layout_id');

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
