use utf8;
package OokOok::Schema::Result::Layout;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::Layout

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

=head1 TABLE: C<layout>

=cut

__PACKAGE__->table("layout");

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

=head2 theme_layout_uuid

  data_type: 'char'
  is_nullable: 0
  size: 20

=head2 type

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 configuration

  data_type: 'text'
  default_value: '{}'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "edition_id",
  { data_type => "integer", is_nullable => 0 },
  "uuid",
  { data_type => "char", is_nullable => 0, size => 20 },
  "theme_layout_uuid",
  { data_type => "char", is_nullable => 0, size => 20 },
  "type",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "configuration",
  { data_type => "text", default_value => "{}", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-05-29 18:18:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QBKct+CKk4KFuTwhViR/KA

__PACKAGE__ -> belongs_to('edition' => 'OokOok::Schema::Result::Edition', "edition_id");

with 'OokOok::Role::Schema::Result::HasVersions';

sub render {
  my($self, $c, $page) = @_;

  my $edition = $c -> stash -> {edition} || $self -> edition;
  my $super_layout = $edition -> theme_layout($self -> theme_layout_uuid);
  if($super_layout) {
    $super_layout -> render($c, $self -> configuration, $page);
  }
  else {
    $c -> response -> content_type('text/html; charset=utf-8');
    my($title, $desc) = ($page -> title, $page -> description);
    my($body) = $page -> page_parts -> find({ name => 'body' }) -> first;
    if($body) {
      $body = $body -> content;
    }
    else {
      $body = "<p>No Content</p>";
    }
    $c -> response -> body(<<EODOC);
<html>
  <head><title>$title</title></head>
  <body><p><em>Description:</em> $desc</p>
        $body
  </body>
</html>
EODOC
  }
  return 1;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
