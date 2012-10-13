use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::Project

# ABSTRACT: a project

editioned_table OokOok::Schema::Result::Project {

  has_editions 'OokOok::Schema::Result::Edition';

  owns_many pages    => 'OokOok::Schema::Result::Page';
  owns_many snippets => 'OokOok::Schema::Result::Snippet';
  owns_many assets   => 'OokOok::Schema::Result::Asset';

  owns_many library_projects => 'OokOok::Schema::Result::LibraryProject';

  after insert {
    my $ce = $self -> current_edition;
  
    # now add libraries that should be included automatically
    my @libs = $self -> result_source -> schema-> resultset('Library') -> all;
    for my $lib (@libs) {
      # we should filter out any libraries without a published edition
      next unless $lib -> new_project_prefix && $lib -> has_public_edition;

      my $pl = $self -> create_related('library_projects', {
        library_id => $lib -> id
      });
      $pl -> insert_or_update;
      $pl -> current_version -> update({
        prefix => $lib -> new_project_prefix
      });
    }

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
    
    $self;
  }

  method page_count { $self -> pages -> count + 0 }

  method page (Str $uuid) {
    $self -> pages -> find({ uuid => $uuid });
  }
}
