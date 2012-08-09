use utf8;
package OokOok::Schema::Result::PageVersion;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::PageVersion

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

=head1 TABLE: C<page_version>

=cut

__PACKAGE__->table("page_version");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 edition_id

  data_type: 'integer'
  is_nullable: 0

=head2 page_id

  data_type: 'integer'
  is_nullable: 0

=head2 layout

  data_type: 'char'
  is_nullable: 1
  size: 20

=head2 slug

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 parent_page_id

  data_type: 'integer'
  is_nullable: 1

=head2 title

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 primary_language

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 status

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "edition_id",
  { data_type => "integer", is_nullable => 0 },
  "page_id",
  { data_type => "integer", is_nullable => 0 },
  "layout",
  { data_type => "char", is_nullable => 1, size => 20 },
  "slug",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "parent_page_id",
  { data_type => "integer", is_nullable => 1 },
  "title",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "primary_language",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "status",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "description",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-08-04 15:18:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VAWJsTvnyDCz1T/KrzHyGQ

with 'OokOok::Role::Schema::Result::Version';

__PACKAGE__ -> belongs_to( 'edition' => 'OokOok::Schema::Result::Edition', 'edition_id');
__PACKAGE__ -> belongs_to( 'page' => 'OokOok::Schema::Result::Page', 'page_id');
__PACKAGE__ -> belongs_to( 'parent_page' => 'OokOok::Schema::Result::Page', 'parent_page_id');
__PACKAGE__ -> has_many('page_parts' => 'OokOok::Schema::Result::PagePart', 'page_version_id');

sub owner { $_[0] -> page }

sub render {
  my($self, $c) = @_;

  my $edition = $c -> stash -> {edition} || $self -> edition;
  my $layout = $edition -> layout($self -> layout);
  if($layout) {
    return $layout -> render($c->stash, $self);
  }

  return '';
}


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
