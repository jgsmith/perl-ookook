use utf8;
package OokOok::Schema::Result::LibraryEdition;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::LibraryEdition

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

=head1 TABLE: C<library_edition>

=cut

__PACKAGE__->table("library_edition");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 library_id

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

=head2 namespace

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 created_on

  data_type: 'datetime'
  is_nullable: 0

=head2 frozen_on

  data_type: 'datetime'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "library_id",
  { data_type => "integer", is_nullable => 0 },
  "name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "namespace",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "created_on",
  { data_type => "datetime", is_nullable => 0 },
  "frozen_on",
  { data_type => "datetime", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-06-03 17:30:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3i0d9IGxUzXAZf16wtr4iA

with 'OokOok::Role::Schema::Result::Edition';

__PACKAGE__ -> belongs_to("library" => "OokOok::Schema::Result::Library", "library_id");

sub owner { $_[0] -> library; }

__PACKAGE__ -> has_many("functions" => "OokOok::Schema::Result::Function", "library_edition_id");

sub function {
  my($self, $name) = @_;

  return $self -> library -> function_for_date($name, $self -> frozen_on);
}



# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
