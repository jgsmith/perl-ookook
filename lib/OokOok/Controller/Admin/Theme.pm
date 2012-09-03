use CatalystX::Declare;

controller OokOok::Controller::Admin::Theme
   extends OokOok::Base::Admin
{
  use OokOok::Collection::Theme;
  use OokOok::Collection::ThemeLayout;
  use OokOok::Collection::ThemeStyle;
  use OokOok::Collection::ThemeVariable;
  use OokOok::Collection::ThemeEdition;

  action base under '/' as 'admin/theme';

  under base {

    action theme_base (Str $uuid) as '' {
      my $resource = OokOok::Collection::Theme->new(c => $ctx) 
                                              ->resource($uuid);
      if(!$resource) {
        $ctx -> detach(qw/Controller::Root default/);
      }
      $ctx -> stash -> {theme} = $resource;
    }

  }

  under theme_base {
    action theme_style_base (Str $uuid) as 'style' {
      my $theme = $ctx -> stash -> {theme};
      my $style = $theme -> style($uuid);
      if(!$style) {
        return $ctx -> response -> redirect(
          $ctx -> uri_for("/admin/theme/" . $theme->id . "/style")
        );
      }

      $ctx -> stash -> {theme_style} = $style;
    }

    action theme_layout_base (Str $uuid) as 'layout' {
      my $theme = $ctx -> stash -> {theme};
      my $layout = $theme -> layout($uuid);
      if(!$layout) {
        return $ctx -> response -> redirect(
          $ctx -> uri_for("/admin/theme/" . $theme->id . "/layout")
        );
      }

      $ctx -> stash -> {theme_layout} = $layout;
    }

    action theme_asset_base (Str $uuid) as 'asset' {
      my $theme = $ctx -> stash -> {theme};
      my $asset = $theme -> asset($uuid);
      if(!$asset) {
        return $ctx -> response -> redirect(
          $ctx -> uri_for("/admin/theme/" . $theme->id . "/asset")
        );
      }

      $ctx -> stash -> {theme_asset} = $asset;
    }

  }

  under base {

    final action index as '' {
      $ctx -> stash -> {themes} = [
        OokOok::Collection::Theme -> new(c => $ctx) -> resources
      ];
      $ctx -> stash -> {template} = "/admin/top/themes";
    }

    final action theme_new as 'new' {
      if($ctx -> request -> method eq 'POST') {
        # get and validate data
        my $collection = OokOok::Collection::Theme -> new(c => $ctx);
        my $theme = $self -> POST( $ctx, $collection, $ctx -> request -> params );
        if($theme) {
          $ctx -> response -> redirect(
            $ctx->uri_for("/admin/theme/" . $theme -> id)
          );
        }
      }
      $ctx -> stash -> {template} = "/admin/top/themes/new";
    }

  }

  under theme_base {  
    final action theme_view as '' {
      my $uuid = $ctx -> stash -> {theme} -> id;
      $ctx -> response -> redirect(
        $ctx -> uri_for("/admin/theme/$uuid/layout")
      );
    }

    final action theme_settings as 'settings' {
      $ctx -> stash -> {template} = '/admin/theme/settings/settings';
    }

    final action theme_editions as 'editions' {
      $ctx -> stash -> {editions} = $ctx -> stash -> {theme} -> editions;
      $ctx -> stash -> {template} = '/admin/theme/settings/editions';
    }

    final action theme_editions_new as 'editions/new' {
      if($ctx -> request -> method eq 'POST') {
        my $theme = $ctx -> stash -> {theme};
        # really do the new edition
        my $edition_collection = OokOok::Collection::ThemeEdition -> new(c => $ctx);
        $edition_collection -> _POST({});
        $ctx -> response -> redirect(
          $ctx -> uri_for("/admin/theme/" . $theme->id . "/editions")
        );
      }
      $ctx -> stash -> {template} = '/admin/theme/settings/editions/new';
    }

    final action theme_assets as 'asset' {
      $ctx -> stash -> {assets} = [ 
        OokOok::Collection::ThemeAsset -> new(c => $ctx) -> resources 
      ];

      $ctx -> stash -> {template} = "/admin/theme/content/asset";
    }

    final action theme_layouts as 'layout' {
      $ctx -> stash -> {layouts} = [ 
        OokOok::Collection::ThemeLayout -> new(c => $ctx) -> resources 
      ];

      $ctx -> stash -> {template} = "/admin/theme/content/layout";
    }

    final action theme_styles as 'style' {
      $ctx -> stash -> {styles} = [ 
        OokOok::Collection::ThemeStyle -> new(c => $ctx) -> resources 
      ];

      $ctx -> stash -> {template} = "/admin/theme/content/style";
    }

    final action theme_variables as 'variable' {
      $ctx -> stash -> {theme_variables} = [ 
        OokOok::Collection::ThemeVariable -> new(c => $ctx) -> resources 
      ];

      $ctx -> stash -> {template} = "/admin/theme/content/variable";
    }

    final action theme_layout_new as 'layout/new' {
      if($ctx -> request -> method eq 'POST') {
        # get and validate data
        my $theme = $ctx -> stash -> {theme};
        my $collection = OokOok::Collection::ThemeLayout -> new(
          c => $ctx
        );
        my $layout = $self -> POST($ctx, $collection, $ctx -> request -> params);
        if($layout) {
          $ctx -> response -> redirect($ctx->uri_for("/admin/theme/" . $theme -> id . "/layout"));
        }
      }
      $ctx -> stash -> {template} = "/admin/theme/content/layout/new";
    }

    final action theme_style_new as 'style/new' {
      if($ctx -> request -> method eq 'POST') {
        # get and validate data
        my $theme = $ctx -> stash -> {theme};
        my $collection = OokOok::Collection::ThemeStyle -> new(
          c => $ctx
        );
        my $style = $self -> POST($ctx, $collection, $ctx -> request -> params);
        if($style) {
          $ctx -> response -> redirect(
            $ctx->uri_for("/admin/theme/" . $theme -> id . "/style")
          );
        }
      }
      $ctx -> stash -> {template} = "/admin/theme/content/style/new";
    }
  }

  under theme_layout_base {
    final action theme_layout_edit as 'edit' {
      if($ctx -> request -> method eq 'POST') {
        my $layout = $ctx -> stash -> {theme_layout};
        $self -> PUT($ctx, $layout, $ctx -> request -> params);
        my $theme = $ctx -> stash -> {theme};
        $ctx -> response -> redirect(
          $ctx->uri_for("/admin/theme/" . $theme -> id . "/layout")
        );
      }
      else {
        my $layout = $ctx -> stash -> {theme_layout};
        $ctx -> stash -> {form_data} = {
          name => $layout -> name,
          layout => $layout -> layout,
        };
        if($layout -> theme_style) {
          $ctx -> stash -> {form_data} -> {theme_style}
            = $layout -> theme_style -> id;
        }
        if($layout -> parent_layout) {
          $ctx -> stash -> {form_data} -> {parent_layout} 
             = $layout -> parent_layout -> id;
        }
      }
      $ctx -> stash -> {template} = "/admin/theme/content/layout/edit";
    }

    final action theme_layout_preview as 'preview' {
      my $context = OokOok::Template::Context -> new(
        c => $ctx,
        is_mockup => 1,
      );
      my $layout = $ctx -> stash -> {theme_layout};
      $ctx -> stash -> {rendering} = $layout -> render($context);
      $ctx -> stash -> {stylesheets} = [ 
        map {
          $ctx -> uri_for( "/ts/".$layout->theme->id."/style/$_" )
        } $layout -> stylesheets 
      ];
      $ctx -> stash -> {template} = "view/play.tt2";
      $ctx -> forward( $ctx -> view('HTML') );
    }
  }

  under theme_style_base {

    final action theme_style_edit as 'edit' {
      if($ctx -> request -> method eq 'POST') {
        my $style = $ctx -> stash -> {theme_style};
        $self -> PUT($ctx, $style, $ctx -> request -> params);
        my $theme = $ctx -> stash -> {theme};
        $ctx -> response -> redirect(
          $ctx->uri_for("/admin/theme/" . $theme -> id . "/style")
        );
      }
      else {
        my $style = $ctx -> stash -> {theme_style};
        $ctx -> stash -> {form_data} = {
          name => $style -> name,
          styles => $style -> styles,
        };
      }
      $ctx -> stash -> {template} = "/admin/theme/content/style/edit";
    }
  }

  under theme_asset_base {
    final action theme_asset_edit as 'edit' {
      if($ctx -> request -> method eq 'POST') {
        my $asset = $ctx -> stash -> {theme_asset};

        $self -> PUT($ctx, $asset, $ctx -> request -> params);
        #$self -> PUT_raw($ctx, $asset, $ctx -> request -> uploads);

        my $theme = $ctx -> stash -> {theme};
        $ctx -> response -> redirect(
          $ctx -> uri_for("/admin/theme/" . $theme->id, "/asset")
        );
      }
      else {
        my $asset = $ctx -> stash -> {theme_asset};
        $ctx -> stash -> {form_data} = {
          name => $asset -> name,
        };
      }
      $ctx -> stash -> {template} = "/admin/theme/content/asset/edit";
    }
  }
}
