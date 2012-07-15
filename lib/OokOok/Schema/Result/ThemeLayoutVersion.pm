use utf8;
package OokOok::Schema::Result::ThemeLayoutVersion;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::ThemeLayoutVersion

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

=head1 TABLE: C<theme_layout_version>

=cut

__PACKAGE__->table("theme_layout_version");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 theme_layout_id

  data_type: 'integer'
  is_nullable: 0

=head2 theme_edition_id

  data_type: 'integer'
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 parent_layout_id

  data_type: 'integer'
  is_nullable: 1

=head2 layout

  data_type: 'text'
  default_value: '<row><div width="12"><page-part name="body"/></div></row>'
  is_nullable: 0

=head2 configuration

  data_type: 'text'
  default_value: '{}'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "theme_layout_id",
  { data_type => "integer", is_nullable => 0 },
  "theme_edition_id",
  { data_type => "integer", is_nullable => 0 },
  "name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "parent_layout_id",
  { data_type => "integer", is_nullable => 1 },
  "layout",
  {
    data_type     => "text",
    default_value => "<row><div width=\"12\"><page-part name=\"body\"/></div></row>",
    is_nullable   => 0,
  },
  "configuration",
  { data_type => "text", default_value => "{}", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-07-14 09:28:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:C/GpPomsXtwuh/Ptd30jTw

with 'OokOok::Role::Schema::Result::Version';

__PACKAGE__ -> belongs_to( edition => 'OokOok::Schema::Result::ThemeEdition', 'theme_edition_id' );

__PACKAGE__ -> belongs_to( layout => 'OokOok::Schema::Result::ThemeLayout', 'theme_layout_id' );

__PACKAGE__ -> belongs_to( parent_layout => 'OokOok::Schema::Result::ThemeLayout', 'parent_layout_id' );

sub owner { $_[0] -> layout }


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
