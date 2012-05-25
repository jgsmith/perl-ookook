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
  "name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "sitemap",
  { data_type => "text", default_value => "{}", is_nullable => 0 },
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


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-05-25 09:58:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eW0wmLnXZHV5nMAQD+Fm6Q

use JSON;
use DateTime;

__PACKAGE__->belongs_to("project" => "OokOok::Schema::Result::Project", "project_id");

__PACKAGE__->has_many("pages" => "OokOok::Schema::Result::Page", "edition_id", {
  cascade_copy => 0,
  cascade_delete => 1,
});
__PACKAGE__->has_many("layouts" => "OokOok::Schema::Result::Layout", "edition_id", {
  cascade_copy => 0,
  cascade_delete => 1,
});

__PACKAGE__->inflate_column('sitemap', {
  inflate => sub { JSON::decode_json shift },
  deflate => sub { JSON::encode_json shift },
});

sub is_frozen { defined $_[0] -> frozen_on; }

sub freeze {
  my($self) = @_;

  return if $self -> is_frozen;

  $self -> copy({
    created_on => DateTime -> now,
    frozen_on => undef
  });

  $self -> update({
    frozen_on => DateTime -> now
  });
}

before delete => sub {
  if($_[0] -> is_frozen) {
    die "Unable to delete a frozen project instance";
  }
};

before update => sub {
  if($_[0] -> is_frozen) {
    $_[0] -> discard_changes();
    die "Unable to delete a frozen project instance";
  }
};

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
