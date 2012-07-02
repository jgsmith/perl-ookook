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
  },
  default => 'text/html',
  current_model => 'DB::Project',
  resource_class => 'OokOok::Resource::Project',
  collection_resource_class => 'OokOok::Collection::Project',
);

use OokOok::Resource::Project;
use OokOok::Collection::Project;

#
# base establishes the root slug for the project management
# routes
#

sub base :Chained('/') :PathPart('project') :CaptureArgs(0) { }

###
### Project-specific information/resources
###

=head1 AUTHOR

James Smith,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
