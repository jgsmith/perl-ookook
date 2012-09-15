use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::ThemeStyle

versioned_table OokOok::Schema::Result::ThemeStyle {

  $CLASS -> has_many( 
    theme_layout_versions => 'OokOok::Schema::Result::ThemeLayoutVersion', 
   'theme_style_id'
  );

}
