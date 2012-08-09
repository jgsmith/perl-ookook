package OokOok::Controller::Admin::Project;

use Moose;
use namespace::autoclean;

use DateTime;

use OokOok::Collection::Project;
use OokOok::Collection::Theme;
use OokOok::Resource::Project;
use OokOok::Resource::Theme;

BEGIN {
  extends 'OokOok::Base::Admin';
}

sub base :Chained('/') :PathPart('admin/project') :CaptureArgs(0) { }

sub index :Chained('base') :PathPart('') :Args(0) {
  my($self, $c) = @_;

  $c -> stash -> {projects} = [
    OokOok::Collection::Project -> new(c => $c) -> resources
  ];
  $c -> stash -> {template} = "/admin/top/projects";
}

sub project_new :Chained('base') :PathPart('new') :Args(0) {
  my($self, $c) = @_;

  if($c -> request -> method eq 'POST') {
    # get and validate data
    my $collection = OokOok::Collection::Project -> new(c => $c);
    my $params = $c -> request -> params;
    $params->{theme_date} = "".DateTime->now;
    my $project = $self -> _POST( $c, $collection, $params );
    if($project) {
      $c -> response -> redirect($c->uri_for("/admin/project/" . $project -> id));
    }
  }
  $c -> stash -> {themes} = [ grep { $_ -> source -> has_public_edition } OokOok::Collection::Theme -> new(c => $c) -> resources ];
  $c -> stash -> {template} = "/admin/top/projects/new";
}

sub project_base :Chained('base') :PathPart('') :CaptureArgs(1) {
  my($self, $c, $uuid) = @_;

  my $resource = OokOok::Collection::Project->new(c => $c) ->
                 resource($uuid);
  if(!$resource) {
    $c -> detach(qw/Controller::Root default/);
  }
  $c -> stash -> {resource} = $resource;
  $c -> stash -> {project} = $resource;
}

sub project_view :Chained('project_base') :PathPart('') :Args(0) {
  my($self, $c) = @_;

  my $uuid = $c -> stash -> {resource} -> id;
  $c -> response -> redirect($c -> uri_for("/admin/project/$uuid/page"));
}

sub project_settings :Chained('project_base') :PathPart('settings') :Args(0) {
  my($self, $c) = @_;

  $c -> stash -> {template} = "/admin/project/settings/settings";
}

sub project_edit :Chained('project_base') :PathPart('settings/edit') :Args(0) {
  my($self, $c) = @_;

  my $project = $c -> stash -> {project};

  $c -> stash -> {themes} = [ 
    grep { $_ -> source -> has_public_edition } 
         OokOok::Collection::Theme -> new(c => $c)
                                   -> resources 
  ];
  if($c -> request -> method eq 'POST') {
    my $info = $c -> request -> params;
    if($c -> request -> params -> {update_theme_date}) {
      $info -> {theme_date} = "".DateTime -> now;
    }
    my $res = $self -> PUT($c, $project, $info);
    if($res) {
      $c -> response -> redirect( $c -> uri_for( "/admin/project/" . $project -> id . "/settings" ) );
    }
  }
  else {
    $c -> stash -> {form_data} = {
      name => $project -> name,
      description => $project -> description,
      theme => $project -> theme -> id,
    };
  }
  $c -> stash -> {template} = "/admin/project/settings/settings/edit";
}

sub project_editions :Chained('project_base') :PathPart('editions') :Args(0) {
  my($self, $c) = @_;

  $c -> stash -> {editions} = $c -> stash -> {project} -> editions;
  $c -> stash -> {template} = "/admin/project/settings/editions";
}

sub project_editions_new :Chained('project_base') :PathPart('editions/new') :Args(0) {
  my($self, $c) = @_;

  if($c -> request -> method eq 'POST') {
    my $project = $c -> stash -> {project};
    my $edition_collection = OokOok::Collection::Edition -> new(c => $c);
    $edition_collection -> _POST({});
    $c -> response -> redirect(
      $c -> uri_for("/admin/project/" . $project->id . "/editions")
    );
  }
  $c -> stash -> {template} = "/admin/project/settings/editions/new";
}

sub project_snippets :Chained("project_base") :PathPart('snippet') :Args(0) {
  my($self, $c) = @_;

  $c -> stash -> {snippets} = $c -> stash -> {project} -> snippets;
  $c -> stash -> {template} = "/admin/project/content/snippet";
}

sub project_snippet_new :Chained('project_base') :PathPart('snippet/new') :Args(0) {
  my($self, $c) = @_;

  my $project = $c -> stash -> {project};

  if($c -> request -> method eq 'POST') {
    my $collection = OokOok::Collection::Snippet -> new(
      c => $c
    );
    my $snippet;
    eval {
      $snippet = $collection -> _POST(
        $c -> request -> params
      );
    };
    if($@) {
      $c -> stash -> {error_msg} = "Unable to create snippet ($@).";
    }
    else {
      $c -> response -> redirect($c -> uri_for("/admin/project/" . $project->id . "/snippet"));
    }
  }
  $c -> stash -> {template} = "/admin/project/content/snippet/new";
}

sub project_pages :Chained("project_base") :PathPart('page') :Args(0) {
  my($self, $c) = @_;

  $c -> stash -> {template} = "/admin/project/content/page";
}
  
sub project_page_new :Chained('project_base') :PathPart('page/new') :Args(0) {
  my($self, $c) = @_;

  my $project = $c -> stash -> {project};

  if($c -> request -> method eq 'POST') {
    my $collection = OokOok::Collection::Page -> new(
      c => $c
    );
    my $page = $self -> POST($c, $collection, $c -> request -> params);
    if($page) {
      $c -> response -> redirect($c -> uri_for("/admin/project/" . $project->id . "/page"));
    }
  }
  $c -> stash -> {theme} = $project -> theme;
  $c -> stash -> {theme_layouts} = [ grep { defined($_ -> source_version) } OokOok::Collection::ThemeLayout -> new(c => $c) -> resources ];
  $c -> stash -> {template} = "/admin/project/content/page/new";
}

sub project_page_base :Chained('project_base') :PathPart('page') :CaptureArgs(1) {
  my($self, $c, $uuid) = @_;

  my $project = $c -> stash -> {project};
  my $page = $project -> page($uuid);
  if(!$page) {
    return $c -> response -> redirect($c -> uri_for("/admin/project/" . $project->id . "/page"));
  }

  $c -> stash -> {page} = $page;
}

sub project_page_edit :Chained('project_page_base') :PathPart('edit') :Args(0) {
  my($self, $c) = @_;

  my $page = $c -> stash -> {page};
  if($c -> request -> method eq 'POST') {
    my $params = $c -> request -> params;
    my $page_info = {
      title => $params -> {title},
      slug  => $params -> {slug},
      layout => $params -> {theme_layout},
    };

    my $res = $self -> PUT($c, $page, $page_info);
      # now update page parts
      
    if($res) {
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
            c => $c,
            date => $page -> date,
            source => $pp_source
          );
        }
        $self -> PUT($c, $ppr, {
          content => $pp->{content},
          filter => $pp->{filter},
        });
      }
      for my $pp (@{$page -> page_parts || []}) {
        if(!$page_part_names{$pp->name}) {
          $pp -> _DELETE;
        }
      }

      my $project = $c -> stash -> {project};
      $c -> response -> redirect($c -> uri_for("/admin/project/" . $project->id . "/page"));
    }
  }
  else {
    my $form_data = {
      title => $page -> title,
      slug => $page -> slug,
      theme_layout => $page -> layout,
      part => [],
    };
    for my $part (@{$page -> page_parts||[]}) {
      push @{$form_data->{part}}, {
        name => $part -> name,
        content => $part -> content,
        filter => $part -> filter,
      };
    }
    $c -> stash -> {form_data} = $form_data;
  }
  $c -> stash -> {template} = "/admin/project/content/page/edit";
}

1;
