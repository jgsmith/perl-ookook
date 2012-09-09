use OokOok::Declare;

# PODNAME: OokOok::Controller::Admin::Theme

# ABSTRACT: Controller for admin interface for themes

admin_controller OokOok::Controller::Admin::Theme {

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
        $ctx -> response -> redirect(
          $ctx -> uri_for("/admin/theme/" . $theme->id . "/style")
        );
        $ctx -> detach;
      }

      $ctx -> stash -> {theme_style} = $style;
    }

    action theme_layout_base (Str $uuid) as 'layout' {
      my $theme = $ctx -> stash -> {theme};
      my $layout = $theme -> layout($uuid);
      if(!$layout) {
        $ctx -> response -> redirect(
          $ctx -> uri_for("/admin/theme/" . $theme->id . "/layout")
        );
        $ctx -> detach;
      }

      $ctx -> stash -> {theme_layout} = $layout;
    }

    action theme_asset_base (Str $uuid) as 'asset' {
      my $theme = $ctx -> stash -> {theme};
      my $asset = $theme -> asset($uuid);
      if(!$asset) {
        $ctx -> response -> redirect(
          $ctx -> uri_for("/admin/theme/" . $theme->id . "/asset")
        );
        $ctx -> detach;
      }

      $ctx -> stash -> {theme_asset} = $asset;
    }

    action theme_snippet_base (Str $uuid) as 'snippet' {
      my $theme = $ctx -> stash -> {theme};
      my $snippet = $theme -> snippet($uuid);
      if(!$snippet) {
        $ctx -> response -> redirect(
          $ctx -> uri_for("/admin/theme/" . $theme->id . "/asset")
        );
        $ctx -> detach;
      }

      $ctx -> stash -> {theme_snippet} = $snippet;
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
        my $theme = $self -> POST( $ctx, 
          collection => 'OokOok::Collection::Theme', 
          redirect => 0
        );
        if($theme) {
          $ctx -> response -> redirect(
            $ctx->uri_for("/admin/theme/" . $theme -> id)
          );
          $ctx -> detach;
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
        $self -> POST($ctx, 
          collection => 'OokOok::Collection::ThemeEdition',
          params => {},
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

    final action theme_snippets as 'snippet' {
      $ctx -> stash -> {snippets} = [ 
        OokOok::Collection::ThemeSnippet -> new(c => $ctx) -> resources 
      ];

      $ctx -> stash -> {template} = "/admin/theme/content/snippet";
    }

    final action theme_variables as 'variable' {
      $ctx -> stash -> {theme_variables} = [ 
        OokOok::Collection::ThemeVariable -> new(c => $ctx) -> resources 
      ];

      $ctx -> stash -> {template} = "/admin/theme/content/variable";
    }

    final action theme_layout_new as 'layout/new' {
      if($ctx -> request -> method eq 'POST') {
        $self -> POST($ctx, 
          collection => 'OokOok::Collection::ThemeLayout',
        );
      }
      $ctx -> stash -> {template} = "/admin/theme/content/layout/new";
    }

    final action theme_style_new as 'style/new' {
      if($ctx -> request -> method eq 'POST') {
        $self -> POST($ctx, 
          collection => 'OokOok::Collection::ThemeStyle'
        );
      }
      $ctx -> stash -> {template} = "/admin/theme/content/style/new";
    }
  }

  under theme_layout_base {
    final action theme_layout_edit as 'edit' {
      if($ctx -> request -> method eq 'POST') {
        $self -> PUT($ctx,
          resource => 'theme_layout',
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
        $self -> PUT($ctx,
          resource => 'theme_style',
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
        $self -> PUT($ctx,
          resource => 'theme_asset',
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

  under theme_snippet_base {
    final action theme_snippet_edit as 'edit' {
      if($ctx -> request -> method eq 'POST') {
        my $res = $self -> PUT($ctx, 
          resource => 'theme_snippet',
        );
      }  
      else {
        my $snippet = $ctx -> stash -> {theme_snippet};
        $ctx -> stash -> {form_data} = {
          name => $snippet -> name,
          content => $snippet -> content,
          filter => $snippet -> filter,
          status => $snippet -> status,
        };
      }  
      $ctx -> stash -> {template} = "/admin/theme/content/snippet/edit";
    }

    final action theme_snippet_discard as 'discard' {
      if($ctx -> request -> method eq 'POST') {
        my $snippet = $ctx -> stash -> {theme_snippet};
        if($self -> DELETE($ctx, resource => 'snippet')) {
          my $theme = $ctx -> stash -> {theme};
          $ctx -> response -> redirect(
            $ctx -> uri_for("/admin/theme/" . $theme->id . "/snippet")
          );
        }
      }  
      $ctx -> stash -> {template} = "/admin/theme/content/snippet/discard";
    }
  }
}
