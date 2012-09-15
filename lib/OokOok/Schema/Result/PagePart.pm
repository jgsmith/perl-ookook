use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::PagePart

# ABSTRACT: content for a page part of a project page

Table OokOok::Schema::Result::PagePart {

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


  method page { $self -> page_version -> page; }

  override update ($columns?) {
    $self -> set_inflated_columns($columns) if $columns;
  
    my(%changes) = $self -> get_dirty_columns;
    if($changes{page_version_id}) {
      $self -> discard_changes();
      die "Unable to change the associated page version";
    }

    if($self -> page_version -> edition -> is_closed) {
      # the following will die if we can't duplicate
      $self -> discard_changes();
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
  }
  
  override delete {
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
  }
  
  before insert {
    my $page_version = $self -> page_version;
    if($page_version -> edition -> is_closed) {
      my $page_version = $page_version -> duplicate_to_current_edition;
      $self -> page_version_id($page_version -> id);
    }
  }

}
