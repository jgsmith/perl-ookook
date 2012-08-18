package OokOok::Controller::Admin::Theme;

use Moose;
use namespace::autoclean;

BEGIN {
  extends 'OokOok::Base::Admin';
}

use OokOok::Collection::Theme;
use OokOok::Collection::ThemeVariable;

sub base :Chained('/') :PathPart('admin/theme') :CaptureArgs(0) { }

sub index :Chained('base') :PathPart('') :Args(0) {
  my($self, $c) = @_;

  $c -> stash -> {themes} = [
    OokOok::Collection::Theme -> new(c => $c) -> resources
  ];
  $c -> stash -> {template} = "/admin/top/themes";
}

sub theme_new :Chained('base') :PathPart('new') :Args(0) {
  my($self, $c) = @_;

  if($c -> request -> method eq 'POST') {
    # get and validate data
    my $collection = OokOok::Collection::Theme -> new(c => $c);
    my $theme;
    eval {
      $theme = $collection -> _POST(
        $c -> request -> params
      );
    };
    my $e = $@;
    $c -> stash -> {form_data} = $c -> request -> params;
    if($e && blessed($e) && $e -> isa('OokOok::Exception::PUT')) {
      $c -> stash -> {error_msg} = $e -> message;
      $c -> stash -> {missing} = $e -> missing;
      $c -> stash -> {invalid} = $e -> invalid;
    }
    elsif($theme) {
      $c -> response -> redirect($c->uri_for("/admin/theme/" . $theme -> id));
    }
  }
  $c -> stash -> {template} = "/admin/top/themes/new";
}

sub theme_base :Chained('base') :PathPart('') :CaptureArgs(1) {
  my($self, $c, $uuid) = @_;

  my $resource = OokOok::Collection::Theme->new(c => $c) ->
                 resource($uuid);

  if(!$resource) {
    $c -> detach(qw/Controller::Root default/);
  }

  $c -> stash -> {resource} = $resource;
  $c -> stash -> {theme} = $resource;
}

sub theme_view :Chained('theme_base') :PathPart('') :Args(0) {
  my($self, $c) = @_;
  my $uuid = $c -> stash -> {theme} -> id;
  $c -> response -> redirect($c -> uri_for("/admin/theme/$uuid/layout"));
}

sub theme_settings :Chained('theme_base') :PathPart('settings') :Args(0) {
  my($self, $c) = @_;

  $c -> stash -> {template} = '/admin/theme/settings/settings';
}

sub theme_components :Chained('theme_base') :PathPart('components') :Args(0) {
  my($self, $c) = @_;
}

sub theme_editions :Chained('theme_base') :PathPart('editions') :Args(0) {
  my($self, $c) = @_;

  $c -> stash -> {editions} = $c -> stash -> {theme} -> editions;
  $c -> stash -> {template} = '/admin/theme/settings/editions';
}

sub theme_editions_new :Chained('theme_base') :PathPart('editions/new') :Args(0) {
  my($self, $c) = @_;

  if($c -> request -> method eq 'POST') {
    my $theme = $c -> stash -> {theme};
    # really do the new edition
    my $edition_collection = OokOok::Collection::ThemeEdition -> new(c => $c);
    $edition_collection -> _POST({});
    $c -> response -> redirect(
      $c -> uri_for("/admin/theme/" . $theme->id . "/editions")
    );
  }
  $c -> stash -> {template} = '/admin/theme/settings/editions/new';
}

sub theme_assets :Chained('theme_base') :PathPart('asset') :Args(0) {
  my($self, $c) = @_;

  $c -> stash -> {assets} = [ OokOok::Collection::ThemeAsset -> new(c => $c) -> resources ];

  $c -> stash -> {template} = "/admin/theme/content/asset";
}

sub theme_layouts :Chained('theme_base') :PathPart('layout') :Args(0) {
  my($self, $c) = @_;

  $c -> stash -> {layouts} = [ OokOok::Collection::ThemeLayout -> new(c => $c) -> resources ];

  $c -> stash -> {template} = "/admin/theme/content/layout";
}

sub theme_styles :Chained('theme_base') :PathPart('style') :Args(0) {
  my($self, $c) = @_;

  $c -> stash -> {styles} = [ OokOok::Collection::ThemeStyle -> new(c => $c) -> resources ];
  $c -> stash -> {template} = "/admin/theme/content/style";
}

sub theme_variables :Chained('theme_base') :PathPart('variable') :Args(0) {
  my($self, $c) = @_;

  $c -> stash -> {theme_variables} = [ OokOok::Collection::ThemeVariable -> new(c => $c) -> resources ];
  $c -> stash -> {template} = "/admin/theme/content/variable";
}

sub theme_layout_new :Chained('theme_base') :PathPart('layout/new') :Args(0) {
  my($self, $c) = @_;

  if($c -> request -> method eq 'POST') {
    # get and validate data
    my $theme = $c -> stash -> {theme};
    my $collection = OokOok::Collection::ThemeLayout -> new(
      c => $c
    );
    my $layout;
    eval {
      $layout = $collection -> _POST(
        $c -> request -> params
      );
    };
    my $e = $@;
    if($e && blessed($e) && $e -> isa('OokOok::Exception::PUT')) {
      $c -> stash -> {form_data} = $c -> request -> params;
      $c -> stash -> {error_msg} = $e -> message;
      $c -> stash -> {missing} = $e -> missing;
      $c -> stash -> {invalid} = $e -> invalid;
    }
    else {
      $c -> response -> redirect($c->uri_for("/admin/theme/" . $theme -> id . "/layout"));
    }
  }
  $c -> stash -> {template} = "/admin/theme/content/layout/new";
}

sub theme_style_base :Chained('theme_base') :PathPart('style') :CaptureArgs(1) {
  my($self, $c, $uuid) = @_;

  my $theme = $c -> stash -> {theme};
  my $style = $theme -> style($uuid);
  if(!$style) {
    return $c -> response -> redirect($c -> uri_for("/admin/theme/" . $theme->id . "/style"));
  }

  $c -> stash -> {theme_style} = $style;
}

sub theme_layout_base :Chained('theme_base') :PathPart('layout') :CaptureArgs(1) {
  my($self, $c, $uuid) = @_;

  my $theme = $c -> stash -> {theme};
  my $layout = $theme -> layout($uuid);
  if(!$layout) {
    return $c -> response -> redirect($c -> uri_for("/admin/theme/" . $theme->id . "/layout"));
  }

  $c -> stash -> {theme_layout} = $layout;
}

sub theme_layout_edit :Chained('theme_layout_base') :PathPart('edit') :Args(0) {
  my($self, $c) = @_;

  if($c -> request -> method eq 'POST') {
    my $layout = $c -> stash -> {theme_layout};
    eval {
      $layout -> _PUT($c -> request -> params);
    };
    my $e = $@;
    if($e && blessed($e) && $e -> isa('OokOok::Exception::PUT')) {
      $c -> stash -> {form_data} = $c -> request -> params;
      $c -> stash -> {error_msg} = $e -> message;
      $c -> stash -> {missing} = $e -> missing;
      $c -> stash -> {invalid} = $e -> invalid;
    }
    else {
      my $theme = $c -> stash -> {theme};
      $c -> response -> redirect($c->uri_for("/admin/theme/" . $theme -> id . "/layout"));
    }
  }
  else {
    my $layout = $c -> stash -> {theme_layout};
    $c -> stash -> {form_data} = {
      name => $layout -> name,
      layout => $layout -> layout,
    };
    if($layout -> theme_style) {
      $c -> stash -> {form_data} -> {theme_style}
        = $layout -> theme_style -> id;
    }
    if($layout -> parent_layout) {
      $c -> stash -> {form_data} -> {parent_layout} 
         = $layout -> parent_layout -> id;
    }
  }
  $c -> stash -> {template} = "/admin/theme/content/layout/edit";
}

sub theme_style_new :Chained('theme_base') :PathPart('style/new') :Args(0) {
  my($self, $c) = @_;

  if($c -> request -> method eq 'POST') {
    # get and validate data
    my $theme = $c -> stash -> {theme};
    my $collection = OokOok::Collection::ThemeStyle -> new(
      c => $c
    );
    my $style;
    eval {
      $style = $collection -> _POST(
        $c -> request -> params
      );
    };
    my $e = $@;
    if($e && blessed($e) && $e -> isa('OokOok::Exception::PUT')) {
      $c -> stash -> {form_data} = $c -> request -> params;
      $c -> stash -> {error_msg} = $e -> message;
      $c -> stash -> {missing} = $e -> missing;
      $c -> stash -> {invalid} = $e -> invalid;
    }
    else {
      $c -> response -> redirect($c->uri_for("/admin/theme/" . $theme -> id . "/style"));
    }
  }
  $c -> stash -> {template} = "/admin/theme/content/style/new";
}

sub theme_style_edit :Chained('theme_style_base') :PathPart('edit') :Args(0) {
  my($self, $c) = @_;

  if($c -> request -> method eq 'POST') {
    my $style = $c -> stash -> {theme_style};
    eval {
      $style -> _PUT($c -> request -> params);
    };
    my $e = $@;
    if($e && blessed($e) && $e -> isa('OokOok::Exception::PUT')) {
      $c -> stash -> {form_data} = $c -> request -> params;
      $c -> stash -> {error_msg} = $e -> message;
      $c -> stash -> {missing} = $e -> missing;
      $c -> stash -> {invalid} = $e -> invalid;
    }
    else {
      my $theme = $c -> stash -> {theme};
      $c -> response -> redirect($c->uri_for("/admin/theme/" . $theme -> id . "/style"));
    }
  }
  else {
    my $style = $c -> stash -> {theme_style};
    $c -> stash -> {form_data} = {
      name => $style -> name,
      styles => $style -> styles,
    };
  }
  $c -> stash -> {template} = "/admin/theme/content/style/edit";
}

1;
