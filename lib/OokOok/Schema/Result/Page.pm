use utf8;
package OokOok::Schema::Result::Page;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::Page

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

=head1 TABLE: C<page>

=cut

__PACKAGE__->table("page");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 edition_id

  data_type: 'integer'
  is_nullable: 0

=head2 uuid

  data_type: 'char'
  is_nullable: 0
  size: 20

=head2 title

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 layout

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 description

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "edition_id",
  { data_type => "integer", is_nullable => 0 },
  "uuid",
  { data_type => "char", is_nullable => 0, size => 20 },
  "title",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "layout",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "description",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-05-23 10:31:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Aaxyj7BthjlPiKnYba+W3w

#use Data::UUID;
use Carp;

__PACKAGE__ -> belongs_to( "edition" => "OokOok::Schema::Result::Edition", "edition_id" );

__PACKAGE__ -> has_many( "page_parts" => "OokOok::Schema::Result::PagePart", "page_id", {
  cascade_copy => 1,
  cascade_delete => 1,
} );

with 'OokOok::Role::Schema::Result::HasVersions';

sub render {
  my($self, $c) = @_;

  $c -> response -> content_type('text/html; charset=utf-8');
  my($title, $desc) = ($self -> title, $self -> description);
  my($pp, $content);
  my $q = $self -> page_parts;
  my @content;
  while(defined($pp = $q -> next)) {
    push @content, "<h2>".$pp->name."</h2>" . $pp -> content;
  }
  $content = join("<br/><hr/><br/>", @content);
  $c -> response -> body(<<EODOC);
<html>
  <head><title>$title</title></head>
  <body><p><em>Description:</em> $desc</p><br/><hr/><br/>$content</body>
</html>
EODOC
  return 1;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
