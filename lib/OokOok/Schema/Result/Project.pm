use utf8;
package OokOok::Schema::Result::Project;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::Project

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

=head1 TABLE: C<project>

=cut

__PACKAGE__->table("project");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 uuid

  data_type: 'char'
  is_nullable: 0
  size: 20

=head2 created_on

  data_type: 'datetime'
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "uuid",
  { data_type => "char", is_nullable => 0, size => 20 },
  "created_on",
  { data_type => "datetime", is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-05-26 10:54:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RmBRz2y4VluCdbvE1TGxjQ

__PACKAGE__->has_many(
  editions => 'OokOok::Schema::Result::Edition',
  'project_id'
);

with 'OokOok::Role::Schema::Result::HasEditions';

=head2 edition_for_date

Given a date, find the project instance that is appropriate. If no
date is given, then find the most recent project instance.

=cut

=head2 edition_path

Given a date, return a list of project instances to search through for
the appropriate object.

=cut

sub edition_path {
  my($self, $date) = @_;

  my $q = $self -> editions;

  return $self -> _apply_date_constraint($q, "", $date) -> all;
}

=head2 last_frozen_on

Returns the date of the most recently frozen edition.

=cut

sub last_frozen_on {
  my($self) = @_;

  my $last = $self -> editions -> search(
    { 'frozen_on' => { '!=', undef } },
    { order_by => { -desc => 'id' }, rows => 1 }
  )->first;

  if($last) {
    return $last->frozen_on;
  }
}

sub sitemap_for_date {
  my($self, $date) = @_;

  my $instance = $self -> edition_for_date($date);

  if($instance) {
    return $instance -> sitemap;
  }
  else {
    return +{};
  }
}

sub current_sitemap { $_[0] -> sitemap_for_date; }
  
sub page_for_date {
  my($self, $uuid, $date) = @_;

  return $self -> relation_for_date("Page", $uuid, $date);
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
