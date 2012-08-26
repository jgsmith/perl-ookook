use utf8;
package OokOok::Schema::Result::ThemeEdition;

=head1 NAME

OokOok::Schema::Result::ThemeEdition

=cut

use OokOok::ResultEdition;
use namespace::autoclean;

owns_many style_versions => 'OokOok::Schema::Result::ThemeStyleVersion';
owns_many layout_versions => 'OokOok::Schema::Result::ThemeLayoutVersion';
owns_many snippet_versions => 'OokOok::Schema::Result::ThemeSnippetVersion';
owns_many library_theme_versions => 'OokOok::Schema::Result::LibraryThemeVersion';

# returns all layouts for this edition
sub all_layouts {
  my($self) = @_;

  my @uuids = $self 
    -> result_source -> schema -> resultset('ThemeLayout') -> search({
      "theme_edition.theme_id" => $self -> theme -> id,
      "theme_edition.id" => { "<=" => $self -> id },
    }, {
      join => [ "theme_edition" ],
      select => [ "me.uuid" ],
      distinct => 1,
    }) -> all;
  map { $self -> theme -> layout_for_date($_->uuid, $self -> frozen_on) } @uuids;
}

1;
