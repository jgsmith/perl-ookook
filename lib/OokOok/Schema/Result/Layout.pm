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

=head2 theme_layout_uuid

  data_type: 'char'
  is_nullable: 0
  size: 20

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

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
  "theme_layout_uuid",
  { data_type => "char", is_nullable => 0, size => 20 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
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


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-05-23 13:39:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JebMiomE0xPzrDbpgETEow

__PACKAGE__ -> belongs_to('edition' => 'OokOok::Schema::Result::Edition', "edition_id");

override update => sub {
  my($self, $columns) = @_;

  $self -> set_inflated_columns($columns) if $columns;

  if($self->get_dirty_columns->{"edition_id"}) {
    $self -> discard_changes();
    die "Unable to update a layout's project instance";
  }

  if(!keys %{$self->get_dirty_columns}) {
    $self -> discard_changes();
    return $self;
  }

  if($self -> edition -> is_frozen) {
    # duplicate to current instance if we don't have one already
    # if we do have one, then we die with an error
    my $current_edition = $self -> edition -> project -> current_edition;
    my $new;
    $new = $current_edition -> layouts(
      { name => $self -> name }
    ) -> first;
    if($new) {
      $self -> discard_changes();
      die "Layout already exists in current project instance";
    }
    $new = $self -> copy({
      edition_id => $current_edition->id
    });
    my %columns = $self -> get_dirty_columns;
    $self -> discard_changes();
    return $new -> update(\%columns);
  }
  else {
    super;
  }
};

before insert => sub {
  my($self) = @_;

  if($self -> edition -> is_frozen) {
    die "Unable to modify a frozen project instance";
  }
};

override delete => sub {
  my($self) = @_;

  if($self -> edition -> is_froze) {
    die "Unable to modify a frozen project instance";
  }
  super;
};

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
