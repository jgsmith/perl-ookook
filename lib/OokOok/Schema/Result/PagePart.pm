use utf8;
package OokOok::Schema::Result::PagePart;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::PagePart

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

=head1 TABLE: C<page_part>

=cut

__PACKAGE__->table("page_part");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 page_version_id

  data_type: 'integer'
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 filter

  data_type: 'varchar'
  default_value: 'HTML'
  is_nullable: 0
  size: 32

=head2 content

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "page_version_id",
  { data_type => "integer", is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "filter",
  {
    data_type => "varchar",
    default_value => "HTML",
    is_nullable => 0,
    size => 32,
  },
  "content",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-07-19 14:43:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aB+9Epeg+GIeTbO/PaR1DQ

__PACKAGE__ -> belongs_to("page_version" => "OokOok::Schema::Result::PageVersion", "page_version_id");

sub page { $_[0] -> page_version -> page; }

sub GET {
  my($self, $c, $deep) = @_;

  my $json = {
    _links => {
      self => "".$c->uri_for("/page/" . $self->page->uuid . "/part/" . $self->name),
      collection => "".$c->uri_for("/page/" . $self->page->uuid . "/part"),
      parent => "".$c->uri_for("/page/" . $self->page->uuid),
    },
    name => $self -> name,
  };

  if($deep) {
    $json->{content} = $self -> content;
  }

  return $json;
}


override update => sub {
  my($self, $columns) = @_;

  $self -> set_inflated_columns($columns) if $columns;

  my(%changes) = $self -> get_dirty_columns;
  if($changes{page_version_id}) {
    $self -> discard_changes();
    die "Unable to change the associated page version";
  }

  if($self -> page_version -> edition -> is_closed) {
    # the following will die if we can't duplicate
    my $page_version = $self -> page_version -> duplicate_to_current_edition;
    my $new;
    if($changes{name}) {
      my $copy = $self -> get_from_storage;
      $new = $page_version -> page_parts(
        { name => $copy -> name }
      ) -> first;
    }
    else {
      $new = $page_version -> page_parts(
        { name => $self -> name }
      ) -> first;
    }
    return $new -> update(\%changes);
  }
  else {
    super;
  }
};

override delete => sub {
  my($self) = @_;

  my $page_version = $self -> page_version;
  if($page_version -> edition -> is_closed) {
    $page_version = $page_version -> duplicate_to_current_edition;
    return $page_version -> page_parts(
      { name => $self -> name }
    ) -> first -> delete;
  }
  else {
    super;
  }
};

before insert => sub {
  my($self) = @_;

  my $page_version = $self -> page_version;
  if($page_version -> edition -> is_closed) {
    my $page_version = $page_version -> duplicate_to_current_edition;
    $self -> page_version_id($page_version -> id);
  }
};

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
