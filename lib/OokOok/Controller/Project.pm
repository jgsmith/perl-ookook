package OokOok::Controller::Project;

use Moose;
use namespace::autoclean;

use OokOok::Collection::Project;
use OokOok::Collection::Edition;

use JSON;

BEGIN { 
  extends 'OokOok::Base::REST'; 
}

__PACKAGE__ -> config(
  map => {
  },
  default => 'text/html',
);

#
# base establishes the root slug for the project management
# routes
#

sub base :Chained('/') :PathPart('project') :CaptureArgs(0) { 
  my($self, $c) = @_;

  if($c -> stash -> {development} || $c -> stash -> {date}) {
    $c -> detach(qw/Controller::Root default/);
  }

  $c -> stash -> {development} = 1; # for use by resources/collections

  $c -> stash -> {collection} = OokOok::Collection::Project -> new(c => $c);
}

###
### Project-specific information/resources
###

sub pages :Chained('resource_base') :PathPart('page') :Args(0) :ActionClass('REST') { 
  my($self, $c) = @_;

  $c -> stash -> {collection} = OokOok::Collection::Page -> new(c => $c);
}

sub pages_GET { shift -> collection_GET(@_) }
sub pages_POST { shift -> collection_POST(@_) }

sub editions :Chained('resource_base') :PathPart('edition') :Args(0) :ActionClass('REST') { 
  my($self, $c) = @_;

  $c -> stash -> {collection} = OokOok::Collection::Edition -> new(c => $c);
}

sub editions_GET { shift -> collection_GET(@_) }
sub editions_POST { shift -> collection_POST(@_) }

sub editions_DELETE {
  my($self, $c) = @_;

  # this will try to clear out the current working edition of changes
  # essentially revert back to what we had when we closed the last edition
  eval {
    $c -> stash -> {project} -> source -> current_edition -> delete;
  };

  if($@) { print STDERR "DELETE ERROR: $@\n"; }

  $self -> status_no_content($c);
}

=head1 AUTHOR

James Smith,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
