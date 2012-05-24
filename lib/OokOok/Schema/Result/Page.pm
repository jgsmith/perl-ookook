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

use Data::UUID;
use Carp;

__PACKAGE__ -> belongs_to( "edition" => "OokOok::Schema::Result::Edition", "edition_id" );

__PACKAGE__ -> has_many( "page_parts" => "OokOok::Schema::Result::PagePart", "page_id", {
  cascade_copy => 1,
  cascade_delete => 1,
} );

#
# We want to catch any updates/saves and make sure we duplicate ourselves
# to the newest unfrozen project instance if the one we're attached to
# is frozen
#

override update => sub {
  my($self, $columns) = @_;

  $self -> set_inflated_columns($columns) if $columns;

  my %dirty_columns = $self -> get_dirty_columns;
  if($dirty_columns{"edition_id"}) {
    $self -> discard_changes();
    die "Unable to update a page's project instance";
  }

  if(!keys %dirty_columns) {
    return $self; # nothing to update
  }

  if($self->edition->is_frozen) {
    # duplicate and save duplicate to current project instance
    my $new = $self -> duplicate_to_current_edition;
    $self -> discard_changes();
    return $new->update(\%dirty_columns);
  }
  else {
    return super;
  }
};

sub duplicate_to_current_edition {
  my($self, $current_edition) = @_;

  $current_edition ||= $self -> edition -> project -> current_edition;
  if($current_edition -> is_frozen) {
    $self -> discard_changes();
    confess "Current project instance is frozen. Unable to duplicate page for changes";
  }

  if($current_edition -> pages({ uuid => $self -> uuid })->first) {
    $self -> discard_changes();
    confess "Current project instance already has the page";
  }

  my $new = $self -> copy({
    edition_id => $current_edition -> id
  });
  # now duplicate all of the page parts
  for my $part ($self -> page_parts) {
    $part -> copy({
      page_id => $new->id
    });
  }
  return $new;
}

{
  my $ug = Data::UUID -> new;
  before insert => sub {
    my($self) = @_;

    if($self -> edition->is_frozen) {
      die "Unable to modify a frozen project instance";
    }

    if(!$self -> uuid) {
      my $uuid = substr($ug -> create_b64(),0,20);
      $uuid =~ tr{+/}{-_};
      $self -> uuid($uuid);
    }
  };
}

before delete => sub {
  my($self) = @_;

  if($self -> edition -> is_frozen) {
    die "Unable to modify a frozen project instance";
  }
};

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
