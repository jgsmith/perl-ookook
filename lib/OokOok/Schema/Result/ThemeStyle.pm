use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::ThemeStyle

# ABSTRACT: top-level resource for a theme style

versioned_table OokOok::Schema::Result::ThemeStyle {

  __PACKAGE__ -> has_many( 
    theme_layout_versions => 'OokOok::Schema::Result::ThemeLayoutVersion', 
   'theme_style_id'
  );

}
