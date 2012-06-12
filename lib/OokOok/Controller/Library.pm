package OokOok::Controller::Library;
use Moose;
use namespace::autoclean;

BEGIN {
  extends 'Catalyst::Controller::REST';
  with 'OokOok::Role::Controller::Manager';
  with 'OokOok::Role::Controller::HasEditions';
}

__PACKAGE__ -> config(
  map => {
    'text/html' => [ 'View', 'HTML' ],
  },
  default => 'text/html',
  current_model => 'DB::Library',
);

=head1 NAME

OokOok::Controller::Library - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub base :Chained('/') :PathPart('library') :CaptureArgs(0) { }

=head1 AUTHOR

James Smith,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
