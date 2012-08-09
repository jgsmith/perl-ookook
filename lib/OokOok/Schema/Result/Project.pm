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

=head2 board_id

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "uuid",
  { data_type => "char", is_nullable => 0, size => 20 },
  "board_id",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-07-01 13:25:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DChsPi0zSmJtElf5e4Engg

__PACKAGE__->has_many(
  editions => 'OokOok::Schema::Result::Edition',
  'project_id'
);

__PACKAGE__->has_many(
  pages => 'OokOok::Schema::Result::Page',
  'project_id'
);

__PACKAGE__->has_many(
  snippets => 'OokOok::Schema::Result::Snippet',
  'project_id'
);

#__PACKAGE__ -> has_many(
#  library_projects => 'OokOok::Schema::Result::LibraryProject',
#  'project_id'
#);

__PACKAGE__ -> belongs_to( board => 'OokOok::Schema::Result::Board', 'board_id' );

with 'OokOok::Role::Schema::Result::HasEditions';

after insert => sub {
  my($self) = @_;

  my $ce = $self -> current_edition;
  my $home_page = $self -> create_related('pages', { });

  $home_page -> current_version -> update({
    title => 'Home',
    description => 'Top-level page for the project site.',
    slug => '',
  });
  $ce -> update({
    page_id => $home_page->id
  });

  # now add libraries that should be included automatically
  my @libs = $self -> result_source->schema-> resultset('Library') -> search({
    new_project_prefix => { '!=' => undef }
  });
  for my $lib (@libs) {
    # we should filter out any libraries without a published edition
    #my $pl = $self -> create_related('library_projects', {
    #  library_id => $lib -> id
    #});
    #$pl -> insert_or_update;
    #$pl -> current_version -> update({
    #  prefix => $lib -> new_project_prefix
    #});
  }
    
  $self;
};

sub page_count { $_[0] -> pages -> count + 0 }

sub page {
  my($self, $uuid) = @_;

  $self -> pages -> find({ uuid => $uuid });
}

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


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
