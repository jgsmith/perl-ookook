use utf8;
package OokOok::Schema::Result::Library;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::Library

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

=head1 TABLE: C<library>

=cut

__PACKAGE__->table("library");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 uuid

  data_type: 'char'
  is_nullable: 0
  size: 20

=head2 collective_id

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "uuid",
  { data_type => "char", is_nullable => 0, size => 20 },
  "collective_id",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-06-24 14:42:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DcOya95a+EI9hwixwBmIRQ

__PACKAGE__->has_many(
  "editions" => 'OokOok::Schema::Result::LibraryEdition',
  'library_id'
);

with 'OokOok::Role::Schema::Result::HasEditions';

sub link {
  my($self, $c) = @_;

  return "".$c -> uri_for("/library/" . $self -> uuid);
}

sub GET {
  my($self, $c, $deep) = @_;

  my $json = {
    _links => {
      self => $self -> link($c),
    },
  };

  return $json;
}

sub function_for_date {
  my($self, $uuid, $date) = @_;

  return $self -> relation_for_date("Function", $uuid, $date);
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
