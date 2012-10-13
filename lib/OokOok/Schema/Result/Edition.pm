use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::Edition

# ABSTRACT: an edition of a project

table_edition OokOok::Schema::Result::Edition {

  use JSON;

  prop default_status => (
    data_type => 'integer',
    default_value => 0,
    is_nullable => 0,
  );

  prop primary_language => (
    data_type => 'varchar',
    size => 255,
    default_value => '',
    is_nullable => 0,
  );

  references_own home_page => 'OokOok::Schema::Result::Page';

  references theme => 'OokOok::Schema::Result::Theme';

  owns_many page_versions => "OokOok::Schema::Result::PageVersion";
  owns_many snippet_versions => "OokOok::Schema::Result::SnippetVersion";
  owns_many asset_versions => "OokOok::Schema::Result::AssetVersion";

  owns_many library_project_versions => "OokOok::Schema::Result::LibraryProjectVersion";

  around close {
    my $next = $self->$orig(@_);
    return unless $next;

    # any pages or snippets that aren't published should be moved to the next
    # edition
    $self -> move_statused_resources($next, [qw/
      page_versions 
      snippet_versions 
      asset_versions
    /]);

    $self -> close_resources([qw/
      page_versions 
      snippet_versions 
      asset_versions 
      library_project_versions
    /]);

    return $next;
  }

  after delete {
    # now we want to delete any pages or snippets that don't have versions
    eval { $_ -> delete } for
        grep { $_ -> versions -> count == 0 }
             $self -> project -> pages, $self -> project -> snippets, $self -> project -> assets;
  }
}
