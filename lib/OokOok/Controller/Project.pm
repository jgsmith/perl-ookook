package OokOok::Controller::Project;
use Moose;
use namespace::autoclean;
use JSON;

BEGIN { 
  extends 'Catalyst::Controller::REST'; 
  with 'OokOok::Role::Controller::Manager';
  with 'OokOok::Role::Controller::HasEditions';
  with 'OokOok::Role::Controller::HasPages';
}

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
  current_model => 'DB::Project',
);

#
# base establishes the root slug for the project management
# routes
#

sub base :Chained('/') :PathPart('project') :CaptureArgs(0) { }

sub project_from_json {
  my($self, $c, $json) = @_;

  my $project = $c -> model("DB::Project") -> new_result({});
  $project -> insert;
  $project -> current_edition -> update({
    name => $json -> {name},
    description => $json -> {description},
  });
  #print STDERR "Made project: $project\n";
  return $project;
}

sub project_to_json {
  my($self, $c, $project, $deep) = @_;

  my $ce = $project -> current_edition;
  my $json = {
    name => $ce -> name,
    description => $ce -> description,
    uuid => $project -> uuid,
    url => "".$c -> uri_for("/project/" . $project -> uuid),
    editions => [ map { $self -> edition_to_json($c, $_) } $project -> editions -> all ],
  };
  return $json;
}

sub update_project {
  my($self, $c, $project, $json) = @_;

  my $ce = $project -> current_edition;

  eval {
    my $updates = {
      name => $json -> {name},
      description => $json -> {description},
    };

    for (qw/name description/) {
      delete $updates->{$_} unless defined $updates->{$_};
    }

    $ce = $ce -> update($updates) if scalar(keys %$updates);
  };
  return $project;
}

sub edition_to_json {
  my($self, $c, $edition) = @_;

  my $json = {
    url => "".$c->uri_for("/project/" . $edition->project->uuid . "/edition"),
    name => $edition -> name,
    description => $edition -> description,
    frozen_on => (map { $_ ? $_->strftime('%Y%m%d%H%M%S') : undef } $edition->frozen_on),
    created_on => (map { $_ ? $_->strftime('%Y%m%d%H%M%S') : undef } $edition->created_on),
  };
  return $json;
}


###
### Project-specific information/resources
###

sub sitemap :Chained('thing_base') :PathPart('sitemap') :Args(0) :ActionClass('REST') { }

sub sitemap_GET {
  my($self, $c) = @_;


  $self -> status_ok($c,
    entity => $c -> stash -> {edition} -> sitemap,
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

  $c -> stash(edition => $c -> stash -> {edition} -> update({
    sitemap => $sitemap
  }));

  $self -> status_ok($c,
    entity => $c -> stash -> {edition} -> sitemap,
  );
}

sub sitemap_OPTIONS {
  my($self, $c) = @_;

  $self -> do_OPTIONS($c,
    Allow => [qw/GET OPTIONS PUT/],
    Accept => [qw{application/json}],
  );
}

sub constrain_pages {
  my($self, $c, $q) = @_;

  return $q -> search(
    { 
      "edition.project_id" => $c -> stash -> {project} -> id
    },
    { 
      join => [qw/edition/]
    } 
  );
}

sub page_base :Chained('thing_base') :PathPart('page') :CaptureArgs(1) {
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
    my($pp, $info, $page_part);
    while(($pp, $info) = each(%$parts)) {
      if(exists $info->{content}) {
        
        $page_part = $page -> page_parts -> find({ name => $pp }) -> update({
          content => $info->{content}
        });
        $page = $page_part -> page;
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
