use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::ThemeEdition;

table_edition OokOok::Schema::Result::ThemeEdition {

  owns_many style_versions => 'OokOok::Schema::Result::ThemeStyleVersion';
  owns_many layout_versions => 'OokOok::Schema::Result::ThemeLayoutVersion';
  owns_many asset_versions => 'OokOok::Schema::Result::ThemeAssetVersion';
  owns_many snippet_versions => 'OokOok::Schema::Result::ThemeSnippetVersion';
  owns_many library_theme_versions => 'OokOok::Schema::Result::LibraryThemeVersion';

  around close {
    my $next = $self -> $orig(@_);
    return unless $next;

    $self -> move_statused_resources($next, [qw/
      style_versions
      layout_versions
      asset_versions
      snippet_versions
    /]);

    $self -> close_resources([qw/
      style_versions
      layout_versions
      asset_versions
      library_theme_versions
    /]);

    return $next;
  }

  after delete {
    eval { $_ -> delete } for
      grep { $_ -> versions -> count == 0 }
        $self -> theme -> theme_styles,
        $self -> theme -> theme_layouts,
        $self -> theme -> theme_assets,
      ;
  }
}
