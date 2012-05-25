package OokOok::Controller::Project;
use Moose;
use namespace::autoclean;

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

=head2 base

=cut

sub base :Chained('/') :PathPart('project') :CaptureArgs(1) {
  my($self, $c, $project_id) = @_;

  $c -> stash(resultset => $c->model('DB::Project'));

  my $project;
  if($project_id =~ /^[-A-Za-z0-9_]{20}$/) {
    $project = $c -> stash -> {resultset} -> find_by_uuid($project_id);
  }
  elsif($project_id =~ /^[0-9]+$/) {
    $project = $c -> stash -> {resultset} -> find_by_id($project_id);
  }
  if(!$project) {
    $self -> status_not_found($c,
      message => "Project not found"
    );
    $self -> detach();
  }
}

# We want to produce a list of possible projects
sub index :Chained('/') :PathPart('project') :Args(0) :ActionClass('REST') {
  my($self, $c) = @_;

  $c -> stash(resultset => $c -> model('DB::Project'));
}

sub _list_projects {
  my($self, $c) = @_;
  my @projects;

  for my $project ($c->stash->{resultset}->search({},{ order_by => 'name' })->all) {
    my $p = {
      name => $project->name,
      last_frozen_on => $project->last_frozen_on,
      uuid => $project->uuid,
      id => $project->id,
    };

    my $ce = $project->current_edition;
    $p->{current_edition} = {
      description => $ce->description,
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
sub index_PUT {
  my($self, $c) = @_;

  my $project;
  eval {
    $project = $c->stash->{resultset} -> new_result({
      name => $c->req->data->{name}
    });
    $project -> insert;
    $project -> current_edition -> update({
      description => $c->req->data->{description}
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
          name => $project -> name,
          last_frozen_on => undef,
          uuid => $project->uuid,
          id => $project->id,
        },
        projects => $self -> _list_projects($c)
      }
    );
  }
}


=head2 project

=cut

# Handles operations on a particular project
sub project :Chained('base') :PathPart('') :Args(0) :ActionClass('REST') { }


# We want to show the project dashboard if requesting HTML
# Otherwise, we assemble info about the working edition and send it to
# the client.
sub project_GET {
  my ( $self, $c ) = @_;

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
