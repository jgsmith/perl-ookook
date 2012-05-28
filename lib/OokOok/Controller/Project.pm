package OokOok::Controller::Project;
use Moose;
use namespace::autoclean;
use JSON;

BEGIN { extends 'Catalyst::Controller::REST'; }

=head1 NAME

OokOok::Controller::Project - Catalyst Controller

=head1 DESCRIPTION

Provides the REST API for project management used by the project management
web pages. These should not be considered a general purpose API.

=head1 METHODS

=cut

__PACKAGE__ -> config(
  map => {
    'text/html' => [ 'View', 'HTML' ],
  },
  default => 'text/html',
);

sub status_service_unavailable :Private {
  my($self, $c, %p) = @_;
  $c -> response -> status(503);
  $c->log->debug( "Status Service Unavailable: $p{message}" ) if $c -> debug;
  $c -> stash -> { $self -> {'stash_key'} } = {
    error => $p{message}
  };
  return 1;
}

# We want to produce a list of possible projects
sub index :Chained('/') :PathPart('project') :Args(0) :ActionClass('REST') {
  my($self, $c) = @_;

  $c -> stash(resultset => $c -> model('DB::Project'));
}

sub _list_projects {
  my($self, $c) = @_;
  my @projects;

  #
  # TODO: make the sort happen in the database -- we actually want to
  # sort by last action, but most recently created working edition
  # works for now.
  #
  for my $project (sort { $b -> current_edition -> id <=> $a -> current_edition -> id } $c->stash->{resultset}->all) {
    my $ce = $project->current_edition;
    my $p = {
      name => $ce->name,
      last_frozen_on => (map { defined($_) ? "".$_ : "" } $project -> last_frozen_on),
      uuid => $project->uuid,
      description => $ce -> description,
    };

    push @projects, $p;
  }

  return [@projects];
}


# List projects
sub index_GET {
  my($self, $c) = @_;

  $self -> status_ok(
    $c,
    entity => {
      projects => $self -> _list_projects($c)
    }
  );
}

# Create project.
sub index_POST {
  my($self, $c) = @_;

  my($project, $ce);
  eval {
    $project = $c->stash->{resultset} -> new_result({ });
    $project -> insert;
    $ce = $project -> current_edition;
    $ce -> update({
      name => $c->req->data->{name},
      description => $c->req->data->{description},
    });
  };

  if($@) {
    $self -> status_bad_request(
      $c,
      message => "Unable to create project: $@",
    );
  }
  else {
    $self -> status_created(
      $c,
      location => $c -> uri_for('/project') . '/' . $project -> uuid,
      entity => {
        project => {
          name => $ce -> name,
          description => $ce -> description,
          last_frozen_on => (map { defined($_) ? "".$_ : "" } $project -> last_frozen_on),
          uuid => $project->uuid,
        },
        projects => $self -> _list_projects($c)
      }
    );
  }
}

sub do_OPTIONS :Private {
  my($self, $c, %headers) = @_;

  $c -> response -> status(200);
  $c -> response -> headers -> header(%headers);
  $c -> response -> body('');
  $c -> response -> content_length(0);
  $c -> response -> content_type("text/plain");
  $c -> detach();
}

sub index_OPTIONS {
  my($self, $c) = @_;

  $self -> do_OPTIONS( $c,
    Allow => [qw/GET OPTIONS POST/],
    Accept => [qw{application/json}],
  );
}


=head2 project

=cut

=head2 base

=cut

sub base :Chained('/') :PathPart('project') :CaptureArgs(1) {
  my($self, $c, $project_id) = @_;

  $c -> stash(resultset => $c->model('DB::Project'));

  my $project;
  if($project_id =~ /^[-A-Za-z0-9_]{20}$/) {
    $project = $c -> stash -> {resultset} -> find({ uuid => $project_id});
  }
  if(!$project) {
    $self -> status_not_found($c,
      message => "Project not found"
    );
    $c -> detach();
  }
  $c -> stash -> {project} = $project;
  $c -> stash -> {edition} = $project -> current_edition;
}

# Handles operations on a particular project
sub project :Chained('base') :PathPart('') :Args(0) :ActionClass('REST') { }


# We want to show the project dashboard if requesting HTML
# Otherwise, we assemble info about the working edition and send it to
# the client.
sub project_GET {
  my ( $self, $c ) = @_;

  my $p = $c->stash->{project};
  my $ce = $c->stash->{edition};
  my $data = {
    name => $ce->name,
    uuid => $p -> uuid,
    url => $c->uri_for("/project") . '/' . $p -> uuid,
    description => $ce -> description,
    editions => [
      map { +{
        frozen_on => (map { defined($_) ? "".$_ : "" } $_ -> frozen_on),
        created_on => (map { defined($_) ? "".$_ : "" } $_ -> created_on),
        name => $_ -> name,
        description => $_ -> description,
      } } $p -> editions -> search({}, { order_by => 'id' }) -> all
    ],
  };

  $self -> status_ok(
    $c,
    entity => {
      project => $data
    }
  );
}

#
# PUT must be idempotent -- so no new working edition
#
sub project_PUT {
  my( $self, $c ) = @_;

  my($project, $ce) = @{$c -> stash}{qw/project edition/};
  eval {
    my $updates = {
      name => $c -> req -> data -> {name},
      description => $c -> req -> data -> {description},
    };
    delete $updates->{name} unless defined $updates->{name};
    delete $updates->{description} unless defined $updates->{description};

    $ce -> update($updates) if scalar(keys %$updates);
  };
  
  if($@) {
    $self -> status_bad_request(
      $c,
      message => "Unable to update project: $@",
    );
  }
  else {
    my $data = {
      name => $ce->name,
      uuid => $project -> uuid,
      url => $c->uri_for("/project") . '/' . $project -> uuid,
      description => $ce -> description,
      editions => [
        map { +{
          frozen_on => (map { defined($_) ? "".$_ : "" } $_ -> frozen_on),
          created_on => (map { defined($_) ? "".$_ : "" } $_ -> created_on),
          name => $_ -> name,
          description => $_ -> description,
        } } $project -> editions -> search({}, { order_by => 'id' }) -> all
      ],
    };
    $self -> status_ok(
      $c,
      entity => {
        project => $data
      }
    );
  }
}

sub project_DELETE {
  my( $self, $c ) = @_;

  eval {
    $c -> stash -> {project} -> delete;
  };

  if($@) {
    $self -> status_forbidden($c, entity => { message => 'unable to delete project' });
  }
  else {
    $self -> status_ok($c, entity => { message => 'success' });
  }
}
    
sub project_OPTIONS {
  my($self, $c) = @_;

  $self -> do_OPTIONS($c,
    Allow => [qw/GET OPTIONS PUT DELETE/],
    Accept => [qw{application/json}],
  );
}

sub edition :Chained('base') :PathPart('edition') :Args(0) :ActionClass('REST') { }

sub edition_GET {
  my($self, $c) = @_;

  my $edition = $c -> stash -> {edition};

  $self -> status_ok(
    $c,
    entity => {
      edition => {
        created_on => "".$edition->created_on,
        description => $edition->description,
        name => $edition->name
      }
    }
  );
}

# We will want protections here so people don't get tricked into freezing
# a working edition
sub edition_POST {
  my($self, $c) = @_;

  my $edition = $c -> stash -> {edition};

  if($edition -> created_on < DateTime->now) {
    $edition -> freeze;
    my $edition = $c -> stash -> {project} -> current_edition;
    $self -> status_ok(
      $c,
      entity => {
        edition => {
          created_on => "".$edition->created_on,
          description => $edition->description,
          name => $edition->name
        }
      }
    );
  }
  else {
    $self -> status_service_unavailable($c, 
      message => "Previous working edition too recent"
    );
  }
}

# DELETE will effectively clear out the current working edition
# the current edition is deleted and a new one is created
sub edition_DELETE {
  my($self, $c) = @_;

  eval {
    $c -> stash -> {edition} -> delete;
  };

  if($@) {
    $self -> status_forbidden($c, entity => { message => 'unable to clear edition' });
  }
  else {
    $self -> status_ok($c, entity => { message => 'success' });
  }
}


sub sitemap :Chained('base') :PathPart('sitemap') :Args(0) :ActionClass('REST') { }

sub sitemap_GET {
  my($self, $c) = @_;


  $self -> status_ok(
    $c,
    entity => {
      sitemap => $c -> stash -> {edition} -> sitemap
    }
  );
}

sub _walk_sitemaps {
  my($self, $sitemap, $changes) = @_;

  my($k, $v, $kk, $vv);

  while(($k, $v) = each(%$changes)) {
    if(!exists $sitemap->{$k}) {
      $sitemap->{$k} = { };
    }
    while(($kk, $vv) = each(%$v)) {
      if($kk eq 'children') {
        if(!exists $sitemap -> {$k} -> {children}) {
          $sitemap->{$k} -> {children} = {};
        }
        $self -> _walk_sitemaps($sitemap -> {$k} -> {children}, $vv);
        if(0 == scalar(keys %{$sitemap->{$k}->{children}})) {
          delete $sitemap->{$k}->{children};
        }
      }
      elsif(defined $vv) {
        $sitemap -> {$k} -> {$kk} = $vv;
      }
      elsif(exists $sitemap->{$k}->{$kk}) {
        delete $sitemap->{$k}->{$kk};
      }
    }
    if(!scalar(keys(%{$sitemap->{$k}}))) {
      delete $sitemap->{$k};
    }
  }
}

sub sitemap_PUT {
  my($self, $c) = @_;

  # we walk through the pieces we're given and add, remove, or
  # modify them as needed.
  #
  # { 'slug' => { children => { ... }, foo => undef }
  #   => remove foo representation of 'slug'
  #
  #

  my $sitemap = $c -> stash -> {edition} -> sitemap;

  my $changes = $c -> req -> data;

  $self -> _walk_sitemaps($sitemap, $changes);

  $c -> stash -> {edition} -> update({
    sitemap => $sitemap
  });

  $self -> status_ok(
    $c,
    entity => {
      sitemap => $c -> stash -> {edition} -> sitemap
    }
  );
}

sub sitemap_OPTIONS {
  my($self, $c) = @_;

  $self -> do_OPTIONS($c,
    Allow => [qw/GET OPTIONS PUT/],
    Accept => [qw{application/json}],
  );
}


sub pages :Chained('base') :PathPart('page') :Args(0) :ActionClass('REST') { }

#
# TODO: Find more efficient SQL for finding the most recent version of
# each page based on the uuid (without having to load uuid first).
#
sub pages_GET {
  my($self, $c) = @_;

  my %pages;
  my $q = $c -> model("DB::Page");
  
  $q = $q -> search(
    { 
      "edition.project_id" => $c -> stash -> {project} -> id
    },
    { 
      join => [qw/edition/]
    } 
  );

  my $uuid;
   
  while(my $p = $q -> next) {
    $uuid = $p -> uuid;
    if($pages{$uuid}) {
      # we assume that a higher id is a more recent edition
      if($p -> edition -> id > $pages{$uuid}->edition->id) {
        $pages{$uuid} = $p;
      }
    } 
    else {
      $pages{$uuid} = $p;
    } 
  } 
  
  $self -> status_ok(
    $c,
    entity => {
      pages => [
        map { +{
          uuid => $_ -> uuid,
          title => $_ -> title,
          parts => [ map { $_ -> name } $_ -> page_parts ],
        } } values %pages
      ]
    }
  );
}

# Creates a page in the current edition
# No content, but meta info, such as title and layout info
sub pages_POST {
  my($self, $c) = @_;

  my $page;
  eval {
    my %columns;
    my $data = $c -> req -> data;
    for my $col (qw/title description/) {
      $columns{$col} = $data -> {$col} if defined $data -> {$col};
    }

    $page = $c -> stash -> {edition} -> create_related('pages', \%columns);
  };

  if($@) {
    $self -> status_bad_request(
      $c,
      message => "Unable to create page: $@",
    );
  } 
  else {
    my $puuid = $page -> uuid;
    my $uuid = $c -> stash -> {project} -> uuid;
    $self -> status_created(
      $c,
      location => $c -> uri_for("/project/$uuid/page/$puuid"),
      entity => {
        page => {
          uuid => $puuid,
          title => $page -> title,
          description => $page -> description,
        }
      }
    );
  }
}

sub pages_OPTIONS {
  my($self, $c) = @_;

  $self -> do_OPTIONS($c,
    Allow => [qw/GET OPTIONS PUT/],
    Accept => [qw{application/json}],
  );
}

sub page_base :Chained('base') :PathPart('page') :CaptureArgs(1) {
  my($self, $c, $page_uuid) = @_;

  # pulls out most recent version of page object, including working edition
  # version if there is one
  my $page = $c -> stash -> {project} -> page_for_date($page_uuid);

  if($page) {
    $c -> stash -> {page} = $page;
  }
  else {
    $self -> status_not_found($c,
      message => "Page not found"
    );
    $c -> detach();
  }
}

sub page :Chained('page_base') :PathPart('') :Args(0) :ActionClass('REST') { 

}

sub page_GET {
  my($self, $c) = @_;

  my $page = $c -> stash -> {page};

  $self -> status_ok(
    $c,
    entity => {
      page => {
        uuid => $page -> uuid,
        title => $page -> title,
        description => $page -> description,
        parts => [ map { $_ -> name } $page -> page_parts ],
      }
    }
  );
}

sub page_PUT {
  my($self, $c) = @_;

  my $page = $c -> stash -> {page};

  # we can update title or description - nothing else at the moment
  my %columns;
  for my $col (qw/title description/) {
    $columns{$col} = $c -> req -> data -> {$col} if defined $c -> req -> data -> {$col};
  }
  if(%columns) {
    eval {
      $page = $page -> update(\%columns);
    };
    if($@) {
      $self -> status_forbidden($c, message => "unable to update page: $@" );
      $self -> detach;
    }
  }
  if($c -> req -> data -> {page_parts}) {
    my $parts = $c -> req -> data -> {page_parts};
    my $q = $page -> page_parts;
    my $pp;
    while(defined($pp = $q -> next)) {
      if(exists $parts->{$pp->name}) {
        if(exists $parts->{$pp->name}{content}) {
          $pp -> update({
            content => $parts->{$pp->name}{content}
          });
        }
      }
    }
  }
  $self -> status_ok(
    $c,
    entity => {
      page => {
        uuid => $page -> uuid,
        title => $page -> title,
        description => $page -> description,
      }
    }
  );
}

sub page_DELETE {
  my($self, $c) = @_;

  eval {
    $c -> stash -> {page} -> delete;
  };

  if($@) {
    $self -> status_forbidden($c, entity => { message => 'unable to revert page' });
  }
  else {
    $self -> status_ok($c, entity => { message => 'success' });
  }
}

sub page_OPTIONS {
  my($self, $c) = @_;

  $self -> do_OPTIONS($c,
    Allow => [qw/GET OPTIONS PUT DELETE/],
    Accept => [qw{application/json}],
  );
}

#sub page_edit :Chained('page_base') :PathPart('edit') :Args(0) { }

sub page_parts :Chained('page_base') :PathPart('page_part') :Args(0) :ActionClass('REST') {

}

sub page_parts_GET {
  my($self, $c) = @_;

  my %parts;

  my $q = $c -> stash -> {page} -> page_parts;

  my $pp;
  while(defined($pp = $q -> next)) {
    $parts{$pp -> name} = {
      content => $pp -> content
    };
  }

  $self -> status_ok(
    $c,
    entity => {
      page_parts => \%parts
    }
  );
}

sub page_part :Chained('page_base') :PathPart('page_part') :Args(1) :ActionClass('REST') {
  my($self, $c, $part_name) = @_;

  $c -> stash -> {page_part_name} = $part_name;
  my $part = $c -> stash -> {page} -> page_parts -> find({name => $part_name});
  $c -> stash -> {page_part} = $part;
}

sub page_part_OPTIONS {
  my($self, $c) = @_;

  my @allowed = (qw/OPTIONS/);

  if($c -> stash -> {page_part}) {
    push @allowed, qw/GET PUT DELETE/;
  }
  else {
    push @allowed, qw/POST/;
  }

  $self -> do_OPTIONS($c,
    Allow => [@allowed],
    Accept => [qw{application/json}],
  );
}

sub page_part_GET {
  my($self, $c) = @_;

  if(!$c -> stash -> {page_part}) {
    $self -> status_not_found($c,
      message => "Page part not found"
    );
  }
  else {
    $self -> status_ok(
      $c,
      entity => {
        page_part => {
          content => $c -> stash -> {page_part} -> content
        }
      }
    );
  }
}

sub page_part_POST {
  my($self, $c) = @_;

  if($c -> stash -> {page_part}) {
    # error ... we should be creating a new one
    $self -> status_bad_request(
      $c,
      message => "Requested page part already exists"
    );
  }
  else {
    eval {
      my $part = $c -> stash -> {page} -> create_related('page_parts', {
        name => $c -> stash -> {page_part_name},
        content => $c -> req -> data -> {content},
      });
      $c -> stash -> {page_part} = $part;
    };
    if($@) {
      $self -> status_bad_request(
        $c,
        message => "Unable to create page part: $@"
      );
    }
    else {
      $self -> status_ok($c,
        entity => {
          page_part => {
            content => $c -> stash -> {page_part} -> content,
          }
        }
      );
    }
  }
}

sub page_part_PUT {
  my($self, $c) = @_;

  if(!$c -> stash -> {page_part}) {
    $self -> status_not_found($c,
      message => "Page part not found"
    );
    $c -> detach();
  }
  else {
    eval {
      $self -> stash -> {page_part} -> update({
        content => $c -> req -> data -> {content},
      });
    };
    if($@) {
      $self -> status_bad_request(
        $c,
        message => "Unable to update page part: $@"
      );
    }
    else {
      $self -> status_ok(
        $c,
        entity => {
          page_part => {
            content => $c -> stash -> {page_part} -> content
          }
        }
      );
    }
  }
}

sub page_part_DELETE {
  my($self, $c) = @_;

  if(!$c -> stash -> {page_part}) {
    $self -> status_not_found($c,
      message => "Page part not found"
    );
    $c -> detach();
  }
  else {
    eval {
      $c -> stash -> {page_part} -> delete;
    };
    if($@) {
      $self -> status_forbidden($c, entity => { message => 'unable to remove page part' });
    }
    else {
      $self -> status_ok($c, entity => { message => 'success' });
    }
  }
}

=head1 AUTHOR

James Smith,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
