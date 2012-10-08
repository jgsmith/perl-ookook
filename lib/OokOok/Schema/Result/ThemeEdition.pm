use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::ThemeEdition;

table_edition OokOok::Schema::Result::ThemeEdition {

  owns_many style_versions => 'OokOok::Schema::Result::ThemeStyleVersion';
  owns_many layout_versions => 'OokOok::Schema::Result::ThemeLayoutVersion';
  owns_many asset_versions => 'OokOok::Schema::Result::ThemeAssetVersion';
  owns_many snippet_versions => 'OokOok::Schema::Result::ThemeSnippetVersion';
  owns_many library_theme_versions => 'OokOok::Schema::Result::LibraryThemeVersion';

}
