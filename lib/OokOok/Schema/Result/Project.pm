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

=head2 user_id

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "uuid",
  { data_type => "char", is_nullable => 0, size => 20 },
  "user_id",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-05-25 09:54:12
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Dr6PgvQktea5B2hMKG3fHg

use DateTime;
use Data::UUID;

__PACKAGE__->has_many(
  editions => 'OokOok::Schema::Result::Edition',
  'project_id'
);

{
  my $ug = Data::UUID -> new;
  before insert => sub {
    my($self) = @_;

    # we remove the final two '=' since there will always be
    # two of them at the end
    my $uuid = substr($ug -> create_b64(),0,20);
    $uuid =~ tr{+/}{-_};
    $self -> uuid($uuid);
  };
}

after 'insert' => sub {
  my $self = shift;

  # add our first, unfrozen instance
  $self -> create_related('editions', {
    created_on => DateTime -> now
  });
  return $self;
};

# If we have published anything, then we can't be deleted
before 'delete' => sub {
  my $self = shift;

  if(grep { $_ -> is_frozen } $self -> editions) {
    die "Unable to delete a project with published editions";
  }
};

=head2 edition_for_date

Given a date, find the project instance that is appropriate. If no
date is given, then find the most recent project instance.

=cut

sub edition_for_date {
  my($self, $date) = @_;

  my $q = $self -> editions;

  return $self -> _apply_date_constraint($q, "", $date) -> first;
}

sub current_edition { $_[0] -> edition_for_date; }

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
  
sub layout_for_date {
  my($self, $name, $date) = @_;

  my $q = $self -> result_source -> schema -> resultset("Layout");

  $q = $q -> search(
    { 
      "me.name" => $name,
      "edition.project_id" => $self->id
    },
    {
      join => [qw/edition/]
    }
  );

  return $self -> _apply_date_constraint($q, "edition", $date) -> first;
}

#
# Ordering here assumes that primary keys are monotonically increasing in time.
# A fairly safe assumption for 64-bit keys and testing. We would have to
# create almost 300 million per second for a thousand years before we would
# run out of 63-bit keys.
#
sub _apply_date_constraint {
  my($self, $q, $join, $date) = @_;

  if($join ne "") { $join = $join . "." };

  if($date) {
    $q = $q -> search(
      { $join."frozen_on" => { '<=' => $date } },
    );
  }

  $q = $q -> search(
    { },
    { order_by => { -desc => $join.'id' } }
  );

  return $q;
}

sub page_for_date {
  my($self, $uuid, $date) = @_;

  my $q = $self -> result_source -> schema -> resultset("Page");

  #
  # we want to find the right page for the given date
  # pages have uuids that are used to identify them in the sitemap
  #
  # The mapping of URL path to uuid is done elsewhere
  #

  $q = $q -> search(
    { 
      "me.uuid" => $uuid,
      "edition.project_id" => $self->id
    },
    {
      join => [qw/edition/]
    }
  );

  return $self -> _apply_date_constraint($q, "edition", $date) -> first;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
