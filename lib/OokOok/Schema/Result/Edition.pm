use utf8;
package OokOok::Schema::Result::Edition;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::Edition

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

=head1 TABLE: C<edition>

=cut

__PACKAGE__->table("edition");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 project_id

  data_type: 'integer'
  is_nullable: 0

=head2 page_id

  data_type: 'integer'
  is_nullable: 1

=head2 primary_language

  data_type: 'varchar'
  default_value: 'en'
  is_nullable: 0
  size: 32

=head2 name

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 sitemap

  data_type: 'text'
  default_value: '{}'
  is_nullable: 0

=head2 theme_id

  data_type: 'integer'
  is_nullable: 1

=head2 theme_date

  data_type: 'datetime'
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
  "project_id",
  { data_type => "integer", is_nullable => 0 },
  "page_id",
  { data_type => "integer", is_nullable => 1 },
  "primary_language",
  { data_type => "varchar", default_value => "en", is_nullable => 0, size => 32 },
  "name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "sitemap",
  { data_type => "text", default_value => "{}", is_nullable => 0 },
  "theme_id",
  { data_type => "integer", is_nullable => 1 },
  "theme_date",
  { data_type => "datetime", is_nullable => 1 },
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


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-07-15 19:13:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yGhmn5uCgIcABWBDM3/IPA

use JSON;

__PACKAGE__->belongs_to("project" => "OokOok::Schema::Result::Project", "project_id");

__PACKAGE__->belongs_to("page" => "OokOok::Schema::Result::Page", "page_id");

__PACKAGE__->has_many("page_versions" => "OokOok::Schema::Result::PageVersion", "edition_id", {
  cascade_copy => 0,
  cascade_delete => 1,
});
__PACKAGE__->has_many("snippet_versions" => "OokOok::Schema::Result::SnippetVersion", "edition_id", {
  cascade_copy => 0,
  cascade_delete => 1,
});

__PACKAGE__->belongs_to("theme" => "OokOok::Schema::Result::Theme", "theme_id");

__PACKAGE__->inflate_column('sitemap', {
  inflate => sub { JSON::decode_json shift },
  deflate => sub { JSON::encode_json shift },
});

with 'OokOok::Role::Schema::Result::Edition';

sub owner { $_[0] -> project; }

after delete => sub {
  my($self) = @_;

  # now we want to delete any pages or snippets that don't have versions
  map { $_ -> delete } 
      grep { $_ -> versions -> count == 0 }
           $self -> project -> pages, $self -> project -> snippets;
};

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
