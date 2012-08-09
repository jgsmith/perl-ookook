use utf8;
package OokOok::Schema::Result::ThemeSnippetVersion;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::ThemeSnippetVersion

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

=head1 TABLE: C<theme_snippet_version>

=cut

__PACKAGE__->table("theme_snippet_version");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 theme_edition_id

  data_type: 'integer'
  is_nullable: 0

=head2 theme_snippet_id

  data_type: 'integer'
  is_nullable: 0

=head2 status

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 content

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "theme_edition_id",
  { data_type => "integer", is_nullable => 0 },
  "theme_snippet_id",
  { data_type => "integer", is_nullable => 0 },
  "status",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "content",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-08-04 15:18:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DJmYVGjKFqJ6cg2tmqufDQ

with 'OokOok::Role::Schema::Result::Version';

__PACKAGE__ -> belongs_to( edition => 'OokOok::Schema::Result::ThemeEdition', 'theme_edition_id' );
__PACKAGE__ -> belongs_to( theme_edition => 'OokOok::Schema::Result::ThemeEdition', 'theme_edition_id' );

__PACKAGE__ -> belongs_to( theme_snippet => 'OokOok::Schema::Result::ThemeSnippet', 'theme_snippet_id' );

sub owner { $_[0] -> theme_snippet }

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;