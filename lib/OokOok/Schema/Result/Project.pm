use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::Project

# ABSTRACT: a project

editioned_table OokOok::Schema::Result::Project {

  has_editions 'OokOok::Schema::Result::Edition';

  owns_many pages    => 'OokOok::Schema::Result::Page';
  owns_many snippets => 'OokOok::Schema::Result::Snippet';

  after insert {
    my $ce = $self -> current_edition;
    my $home_page = $self -> create_related('pages', { });

    $home_page -> current_version -> update({
      title => 'Home',
      description => 'Top-level page for the project site.',
      slug => '',
    });
    $ce -> update({
      home_page => $home_page
    });
    $ce -> update_or_insert;

    while($ce -> is_changed) {
      $ce -> update_or_insert;
    }
  
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
  }

  method page_count { $self -> pages -> count + 0 }

  method page (Str $uuid) {
    $self -> pages -> find({ uuid => $uuid });
  }
}
