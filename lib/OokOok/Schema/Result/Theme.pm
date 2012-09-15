use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::Theme

editioned_table OokOok::Schema::Result::Theme {

  has_editions;

  owns_many theme_layouts   => 'OokOok::Schema::Result::ThemeLayout';
  owns_many theme_styles    => 'OokOok::Schema::Result::ThemeStyle';
  owns_many theme_snippets  => 'OokOok::Schema::Result::ThemeSnippet';
  owns_many theme_assets    => 'OokOok::Schema::Result::ThemeAsset';
  owns_many theme_variables => 'OokOok::Schema::Result::ThemeVariable';
  owns_many library_themes  => 'OokOok::Schema::Result::LibraryTheme';

  method theme_layout (Str $uuid) {
    $self -> theme_layouts -> find({ uuid => $uuid });
  }

  method theme_style (Str $uuid) {
    $self -> theme_styles -> find({ uuid => $uuid });
  }

  after insert {
    my $ce = $self -> current_edition;
  
    my @libs = $self -> result_source -> schema -> resultset('Library') -> all;
    for my $lib (@libs) {
      next unless $lib -> new_theme_prefix && $lib -> has_public_edition;
  
      my $tl = $self -> create_related('library_themes', {
        library_id => $lib -> id
      });
      $tl -> insert_or_update;
      $tl -> current_version -> update({
        prefix => $lib -> new_theme_prefix
      });
    }

    $self;
  }

}
