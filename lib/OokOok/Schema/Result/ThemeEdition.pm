use utf8;
package OokOok::Schema::Result::ThemeEdition;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::ThemeEdition

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

=head1 TABLE: C<theme_edition>

=cut

__PACKAGE__->table("theme_edition");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 theme_id

  data_type: 'integer'
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 created_on

  data_type: 'datetime'
  is_nullable: 0

=head2 closed_on

  data_type: 'datetime'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "theme_id",
  { data_type => "integer", is_nullable => 0 },
  "name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "created_on",
  { data_type => "datetime", is_nullable => 0 },
  "closed_on",
  { data_type => "datetime", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-06-23 12:03:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wDPcCYyX/o/TOdHEY8jP4A

with 'OokOok::Role::Schema::Result::Edition';

__PACKAGE__ -> belongs_to("theme" => "OokOok::Schema::Result::Theme", "theme_id");

__PACKAGE__ -> has_many("layout_versions" => "OokOok::Schema::Result::ThemeLayoutVersion", "theme_edition_id", {
  cascade_copy => 0,
  cascade_delete => 1,
});

sub owner { $_[0] -> theme; }

# returns all layouts for this edition
sub all_layouts {
  my($self) = @_;

  my @uuids = $self 
    -> result_source -> schema -> resultset('ThemeLayout') -> search({
      "theme_edition.theme_id" => $self -> theme -> id,
      "theme_edition.id" => { "<=" => $self -> id },
    }, {
      join => [ "theme_edition" ],
      select => [ "me.uuid" ],
      distinct => 1,
    }) -> all;
  map { $self -> theme -> layout_for_date($_->uuid, $self -> frozen_on) } @uuids;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
