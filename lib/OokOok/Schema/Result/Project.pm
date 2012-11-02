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

  method home_pages {
    my $q = $self -> result_source -> schema -> resultset('PageVersion') -> search({
      'edition.project_id' => $self -> id,
      'me.page_id' => { '=' => \'"edition"."home_page_id"' },
      'me.published_for' => { '@>' => \'"edition"."published_for"' }
    }, {
      join => 'edition',
      select => [
        'me.id',
        \'"me".published_for * "edition".published_for',
      ],
      as => [qw/id published_for/],
      distinct => 1,
    });
    #print Data::Dumper -> Dump([$q -> as_query]);
    grep { defined($_->[0]) && defined($_->[1]) } map { [ $_ -> id, $_ -> published_for ] } $q -> all;
  }

  method child_page_versions ($slug, $parent_page_version_ids, $dateRange) {
    my $deflated_dateRange = ${OokOok::Util::DB::deflate_tsrange($dateRange)};
    my $q = $self -> result_source -> schema -> resultset('PageVersion') -> search({
      -and => [ \qq{(("me"."published_for" * "versions"."published_for") && $deflated_dateRange)}, ],
      'me.slug' => $slug,
      "versions.id" => $parent_page_version_ids,
    }, {
      join => { parent_page => 'versions' },
      #select => [
      #  'me.id',
      #  \qq{"me"."published_for" * "versions"."published_for" * $deflated_dateRange},
      #],
      #as => [qw(/id published_for/)],
      distinct => 1,
    });

    #print Data::Dumper -> Dump([$q -> as_query]);
    #print Data::Dumper -> Dump([ [ map { [ $_ -> id, ${OokOok::Util::DB::deflate_tsrange($_ -> published_for)} ] } $q -> all ] ]);
    grep { defined($_->[0]) && defined($_->[1]) } map { [ $_ -> id, $_ -> published_for ] } $q -> all;
  }

}
