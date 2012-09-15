use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::Page

# ABSTRACT: a page in a project

versioned_table OokOok::Schema::Result::Page {

  $CLASS -> has_many( 
    children => "OokOok::Schema::Result::PageVersion", 
    parent_page_id => {
      cascade_copy => 0,
      cascade_delete => 0,
    } 
  );

  after insert {
    # make sure we have a 'body' page part
    if(0 == $self -> current_version -> page_parts -> count) {
      my $body = $self -> current_version -> create_related('page_parts', {
        name => 'body',
        content => '',
      });
      $body -> insert_or_update;
    }
  }

}
