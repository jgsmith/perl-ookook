use OokOok::Declare;

admin_controller OokOok::Controller::Admin::Project {
  use DateTime;

  use OokOok::Collection::Theme;
  use OokOok::Resource::Theme;

  action base under '/' as 'admin/project';

  under base {

    action project_base (Str $uuid) as '' {
      my $resource = OokOok::Collection::Project->new(c => $ctx) ->
                     resource($uuid);

      $ctx -> detach(qw/Controller::Root default/) unless $resource;

      $ctx -> stash -> {project} = $resource;
    }

  }

  under project_base {

    action project_page_base (Str $uuid) as 'page' {
      my $page = OokOok::Collection::Page -> new(c => $ctx) -> resource($uuid);
      if(!$page) {
        my $project = $ctx -> stash -> {project};
        $ctx -> response -> redirect(
          $ctx -> uri_for("/admin/project/" . $project->id . "/page")
        );
        $ctx -> detach;
      }

      $ctx -> stash -> {page} = $page;
    }

    action project_snippet_base (Str $uuid) as 'snippet' {
      my $snippet = OokOok::Collection::Snippet -> new(c => $ctx) -> resource($uuid);
      if(!$snippet) {
        my $project = $ctx -> stash -> {project};
        $ctx -> response -> redirect(
          $ctx -> uri_for("/admin/project/" . $project->id . "/snippet")
        );
        $ctx -> detach;
      }

      $ctx -> stash -> {snippet} = $snippet;
    }

  }

  under base {

    final action index as '' {
      $ctx -> stash -> {projects} = [
        OokOok::Collection::Project -> new(c => $ctx) -> resources
      ];
      $ctx -> stash -> {template} = "/admin/top/projects";
    }

    final action project_new as 'new' {
      if($ctx -> request -> method eq 'POST') {
        # get and validate data
        my $guard = $ctx -> model('DB') -> txn_scope_guard;
        my $params = $ctx -> request -> params;
        $params->{theme_date} = DateTime->now -> iso8601;
        my $project = $self -> POST( $ctx, 
          collection => 'OokOok::Collection::Project',
          params => $params,
          redirect => 0,
        );
        if($project) {
          $guard -> commit;
          $ctx -> response -> redirect($ctx->uri_for("/admin/project/" . $project -> id));
          $ctx -> detach;
        }
      }
      $ctx -> stash -> {themes} = [ 
        grep { $_ -> source -> has_public_edition } 
             OokOok::Collection::Theme -> new(c => $ctx) -> resources 
      ];
      $ctx -> stash -> {template} = "/admin/top/projects/new";
    }

  }

  under project_base {
    final action project_view as '' {
      my $uuid = $ctx -> stash -> {project} -> id;
      $ctx -> response -> redirect(
        $ctx -> uri_for("/admin/project/$uuid/page")
      );
    }

    final action project_settings as 'settings' {
      $ctx -> stash -> {template} = "/admin/project/settings/settings";
    }

    final action project_edit as 'settings/edit' {
      my $project = $ctx -> stash -> {project};

      $ctx -> stash -> {themes} = [ 
        grep { $_ -> source -> has_public_edition } 
             OokOok::Collection::Theme -> new(c => $ctx)
                                       -> resources 
      ];
      if($ctx -> request -> method eq 'POST') {
        my $info = $ctx -> request -> params;
        if($ctx -> request -> params -> {update_theme_date}) {
          $info -> {theme_date} = DateTime -> now -> iso8601;
        }
        my $res = $self -> PUT($ctx, 
          resource => $project, 
          params => $info,
          redirect => 0
        );
        if($res) {
          $ctx -> response -> redirect( 
            $ctx -> uri_for( "/admin/project/" . $project -> id . "/settings" )
          );
        }
      }
      else {
        $ctx -> stash -> {form_data} = {
          name => $project -> name,
          description => $project -> description,
          theme => $project -> theme -> id,
        };
      }
      $ctx -> stash -> {template} = "/admin/project/settings/settings/edit";
    }

    final action project_editions as 'editions' {
      $ctx -> stash -> {editions} = $ctx -> stash -> {project} -> editions;
      $ctx -> stash -> {template} = "/admin/project/settings/editions";
    }

    final action project_editions_new as 'editions/new' {
      if($ctx -> request -> method eq 'POST') {
        $self -> POST($ctx,
          collection => 'OokOok::Collection::Edition',
          params => {},
        );
      }
      $ctx -> stash -> {template} = "/admin/project/settings/editions/new";
    }

    final action project_snippets as 'snippet' {
      $ctx -> stash -> {snippets} = $ctx -> stash -> {project} -> snippets;
      $ctx -> stash -> {template} = "/admin/project/content/snippet";
    }

    final action project_snippet_new as 'snippet/new' {
      my $project = $ctx -> stash -> {project};

      if($ctx -> request -> method eq 'POST') {
        my $snippet = $self -> POST($ctx,
          collection => 'OokOok::Collection::Snippet',
        );
      }
      $ctx -> stash -> {template} = "/admin/project/content/snippet/new";
    }

    final action project_pages as 'page' {
      $ctx -> stash -> {template} = "/admin/project/content/page";
    }
  
    final action project_page_new as 'page/new' {
      my $project = $ctx -> stash -> {project};

      if($ctx -> request -> method eq 'POST') {
        my $guard = $ctx -> model('DB') -> txn_scope_guard;
        my $page = $self -> POST($ctx, 
          collection => 'OokOok::Collection::Page',
          redirect => 0,
        );
        if($page) {
          my $do_commit = 1;
          my %page_part_names;
          for my $pp (@{$ctx -> request -> params -> {part} || []}) {
            next unless defined $pp;
            next if $pp->{name} =~ /^\s*$/;
            $page_part_names{$pp->{name}} = 1;
            my $ppr = $page -> page_part($pp->{name});
            if(!$ppr) { # we can create it
              my $pp_source = $page -> source_version -> create_related('page_parts', { name => $pp->{name} });
              $pp_source -> insert;

              $ppr = OokOok::Resource::PagePart->new(
                c => $ctx,
                is_development => $page -> is_development,
                date => $page -> date,
                source => $pp_source
              );

            }
            my $res = $self -> PUT($ctx, 
              resource => $ppr, 
              params => {
                content => $pp->{content},
                filter => $pp->{filter},
              },
              redirect => 0
            );
            if(!$res) {
              $do_commit = 0;
            }
          }
          if($do_commit) {
            $guard -> commit;
            $ctx -> response -> redirect(
              $ctx -> uri_for("/admin/project/" . $project->id . "/page")
            );
          }
        }
      }
      else {
        my $form_data = {
          part => [{
            name => 'body',
            content => '',
            filter => undef,
          }],
        };
        $ctx -> stash -> {form_data} = $form_data;
      }
      $ctx -> stash -> {theme} = $project -> theme;
      $ctx -> stash -> {theme_layouts} = [ 
        grep { defined($_ -> source_version) } 
             OokOok::Collection::ThemeLayout -> new(c => $ctx) -> resources 
      ];
      $ctx -> stash -> {template} = "/admin/project/content/page/new";
    }

  }

  under project_snippet_base {
    final action project_snippet_edit as 'edit' {
      if($ctx -> request -> method eq 'POST') {
        my $res = $self -> PUT($ctx, 
          resource => 'snippet',
        );
      }
      else {
        my $snippet = $ctx -> stash -> {snippet};
        $ctx -> stash -> {form_data} = {
          name => $snippet -> name,
          content => $snippet -> content,
          filter => $snippet -> filter,
          status => $snippet -> status,
        };
      }
      $ctx -> stash -> {template} = "/admin/project/content/snippet/edit";
    }

    final action project_snippet_discard as 'discard' {
      if($ctx -> request -> method eq 'POST') {
        my $snippet = $ctx -> stash -> {snippet};
        if($self -> DELETE($ctx, resource => 'snippet')) {
          my $project = $ctx -> stash -> {project};
          $ctx -> response -> redirect(
            $ctx -> uri_for("/admin/project/" . $project->id . "/snippet")
          );
        }
      }
      $ctx -> stash -> {template} = "/admin/project/content/snippet/discard";
    }
  }
          

  under project_page_base {
    final action project_page_child as 'child' {
      $ctx -> stash -> {parent_page} = $ctx -> stash -> {page};
      $ctx -> forward( 'project_page_new' );
    }

    final action project_page_edit as 'edit' {
      my $page = $ctx -> stash -> {page};
      if($ctx -> request -> method eq 'POST') {
        my $params = $ctx -> request -> params;
        my $page_info = {
          title => $params -> {title},
          slug  => $params -> {slug},
          layout => $params -> {theme_layout},
          status => $params -> {status},
        };
    
        my $guard = $ctx -> model('DB') -> txn_scope_guard;

        my $res = $self -> PUT($ctx, 
          resource => 'page', 
          params => $page_info,
          redirect => 0,
        );

        # now update page parts
          
        if($res) {
          my $do_commit = 1;

          my %page_part_names;
          for my $pp (@{$params->{part} || []}) {
            next unless defined $pp;
            next if $pp->{name} =~ /^\s*$/;
            $page_part_names{$pp->{name}} = 1;
            my $ppr = $page -> page_part($pp->{name});
            if(!$ppr) { # we can create it
              my $pp_source = $page -> source_version -> create_related('page_parts', { name => $pp->{name} });
              $pp_source -> insert;
              $ppr = OokOok::Resource::PagePart->new(
                c => $ctx,
                date => $page -> date,
                source => $pp_source
              );
            }
            $res = $self -> PUT($ctx, 
              resource => $ppr, 
              params => {
                content => $pp->{content},
                filter => $pp->{filter},
              },
              redirect => 0,
            );
            if(!$res) {
              $do_commit = 0;
              last;
            }
          }
          if($do_commit) {
            for my $pp (@{$page -> page_parts || []}) {
              if(!$page_part_names{$pp->name}) {
                $pp -> _DELETE;
              }
            }
          }

          if($do_commit) {
            $guard -> commit;
            my $project = $ctx -> stash -> {project};
            $ctx -> response -> redirect(
              $ctx -> uri_for("/admin/project/" . $project->id . "/page")
            );
          }
        }
      }
      else {
        my $form_data = {
          title => $page -> title,
          slug => $page -> slug,
          theme_layout => $page -> layout,
          part => [],
          status => $page -> status,
        };
        for my $part (@{$page -> page_parts||[]}) {
          push @{$form_data->{part}}, {
            name => $part -> name,
            content => $part -> content,
            filter => $part -> filter,
          };
        }
        $ctx -> stash -> {form_data} = $form_data;
      }
      $ctx -> stash -> {template} = "/admin/project/content/page/edit";
    }

    final action project_page_discard as 'discard' {
      if($ctx -> request -> method eq 'POST') {
        my $page = $ctx -> stash -> {page};
        if($self -> DELETE($ctx, $page)) {
          my $project = $ctx -> stash -> {project};
          $ctx -> response -> redirect(
            $ctx -> uri_for("/admin/project/" . $project->id . "/page")
          );
        }
      }
      $ctx -> stash -> {template} = "/admin/project/content/page/discard";
    }
  }
}
