package OokOok::Controller::Project;
use Moose;
use namespace::autoclean;
use JSON;

BEGIN { extends 'Catalyst::Controller::REST'; }

=head1 NAME

OokOok::Controller::Project - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

__PACKAGE__ -> config(
  map => {
    'text/html' => [ 'View', 'HTML' ],
  },
  default => 'text/html',
);

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
    $self -> detach();
  }
  print STDERR "Project: ", $project -> uuid, "\n";
  $c -> stash -> {project} = $project;
}

# Handles operations on a particular project
sub project :Chained('base') :PathPart('') :Args(0) :ActionClass('REST') { }


# We want to show the project dashboard if requesting HTML
# Otherwise, we assemble info about the working edition and send it to
# the client.
sub project_GET {
  my ( $self, $c ) = @_;

  my $p = $c->stash->{project};
  my $ce = $p -> current_edition;
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

sub project_PUT {
  my( $self, $c ) = @_;

}

sub project_DELETE {
  my( $self, $c ) = @_;

  eval {
    $c -> stash -> {project} -> delete;
  };

  if(!$@) {
    $self -> status_ok($c, entity => { message => 'success' });
  }
  else {
    $self -> status_forbidden($c, entity => { message => 'unable to delete project' });
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
