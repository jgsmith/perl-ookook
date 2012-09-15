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

  around close {
    my $next = $self->$orig(@_);
    return unless $next;

    # any pages or snippets that aren't published should be moved to the next
    # edition
    $self -> page_versions -> search({
      status => { '>' => 0 }
    }) -> update_all({
      edition_id => $next -> id
    });
    $self -> snippet_versions -> search({
      status => { '>' => 0 }
    }) -> update_all({
      edition_id => $next -> id
    });

    return $next;
  };

  after delete {
    # now we want to delete any pages or snippets that don't have versions
    map { eval { $_ -> delete } } 
        grep { $_ -> versions -> count == 0 }
             $self -> project -> pages, $self -> project -> snippets;
  }
}
