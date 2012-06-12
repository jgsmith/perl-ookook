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

=head2 frozen_on

  data_type: 'datetime'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "project_id",
  { data_type => "integer", is_nullable => 0 },
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
  "frozen_on",
  { data_type => "datetime", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-06-03 12:50:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DU4ymAnNS+7FDFBIMyKKBg

use JSON;

__PACKAGE__->belongs_to("project" => "OokOok::Schema::Result::Project", "project_id");

__PACKAGE__->has_many("pages" => "OokOok::Schema::Result::Page", "edition_id", {
  cascade_copy => 0,
  cascade_delete => 1,
});
__PACKAGE__->has_many("layouts" => "OokOok::Schema::Result::Layout", "edition_id", {
  cascade_copy => 0,
  cascade_delete => 1,
});
__PACKAGE__->has_many("snippets" => "OokOok::Schema::Result::Snippet", "edition_id", {
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

#
# We want to get the right theme given the date for which we
# expect the theme.
#
sub theme_edition {
  my($self) = @_;

  if($self -> theme) {
    return $self -> theme -> edition_for_date($self -> theme_date);
  }
}

sub theme_layout {
  my($self, $uuid) = @_;

  if($self -> theme) {
    return $self -> theme -> layout_for_date($uuid, $self -> theme_date);
  }
}

sub layout {
  my($self, $uuid) = @_;

  return $self -> project -> layout_for_date($uuid, $self -> frozen_on);
}

sub snippet {
  my($self, $name) = @_;

  return $self -> project -> snippet_for_date($name, $self -> frozen_on);
}

sub page {
  my($self, $uuid) = @_;

  return $self -> project -> page_for_date($uuid, $self -> frozen_on);
}

sub page_path {
  my($self, @path) = @_;

  my $sitemap = $self -> sitemap;

  my @pages;
  my $page_uuid;

  while(@path && $sitemap) {
    my $slug = shift @path;
    if($sitemap->{$slug}) {
      $page_uuid = $sitemap->{$slug}->{visual};
      $sitemap = $sitemap->{$slug}->{children};
      if($page_uuid) {
        push @pages, $self -> page($page_uuid);
      }
      else {
        push @pages, undef;
      }
    }
  }

  return @pages;
}


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
