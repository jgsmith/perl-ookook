use utf8;
package OokOok::Schema::Result::PagePart;

=head1 NAME

OokOok::Schema::Result::PagePart

=cut

use OokOok::Result;
use namespace::autoclean;

prop name => (
  data_type => 'varchar',
  is_nullable => 0,
  size => 64,
);

prop filter => (
  data_type => 'varchar',
  is_nullable => 0,
  default_value => "HTML",
  size => 64,
);

prop content => (
  data_type => 'text',
  is_nullable => 1,
);


sub page { $_[0] -> page_version -> page; }

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
    $self -> discard_changes();
    print STDERR "Duplicating page to current edition\n";
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
    print STDERR "Updating new page copy page part (", $self -> name, ")\n";
    return $new -> update(\%changes);
  }
  else {
    super;
  }
};

override delete => sub {
  my($self) = @_;

  my $page_version = $self -> page_version;
  if($page_version && $page_version -> edition && $page_version -> edition -> is_closed) {
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

1;
