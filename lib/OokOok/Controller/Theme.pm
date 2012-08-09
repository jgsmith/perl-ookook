package OokOok::Controller::Theme;

use Moose;
use namespace::autoclean;

use JSON;

use OokOok::Collection::Theme;
use OokOok::Collection::ThemeEdition;
use OokOok::Collection::ThemeLayout;
use Carp::Always;

BEGIN { 
  extends 'OokOok::Base::REST'; 
}


__PACKAGE__ -> config(
  map => {
  },
  default => 'text/html',
);

sub base :Chained('/') :PathPart('theme') :CaptureArgs(0) { 
  my($self, $c) = @_;

  if($c -> stash -> {development} || $c -> stash -> {date}) {
    $c -> detach(qw/Controller::Root default/);
  }
  
  $c -> stash -> {development} = 1; # for use by resources/collections

  $c -> stash -> {collection} = OokOok::Collection::Theme -> new(c => $c);
}

sub editions :Chained('resource_base') :PathPart('edition') :Args(0) :ActionClass('REST') {
  my($self, $c) = @_;

  $c -> stash -> {collection} = OokOok::Collection::ThemeEdition -> new(c => $c);
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


sub layouts :Chained('resource_base') :PathPart('theme-layout') :Args(0) :ActionClass('REST') { 
  my($self, $c) = @_;

  $c -> stash -> {collection} = OokOok::Collection::ThemeLayout -> new(c => $c);
}

sub layouts_GET { shift -> collection_GET(@_) }
sub layouts_POST { shift -> collection_POST(@_) }

sub layouts_OPTIONS {
  my($self, $c) = @_;

  $self -> do_OPTIONS($c,
    Allow => [qw/GET OPTIONS POST/],
    Accept => [qw{application/json}],
  );
}


sub styles :Chained('resource_base') :PathPart('theme-style') :Args(0) :ActionClass('REST') { 
  my($self, $c) = @_;

  $c -> stash -> {collection} = OokOok::Collection::ThemeStyle -> new(c => $c);
}

sub styles_GET { shift -> collection_GET(@_) }
sub styles_POST { shift -> collection_POST(@_) }

sub styles_OPTIONS {
  my($self, $c) = @_;

  $self -> do_OPTIONS($c,
    Allow => [qw/GET OPTIONS POST/],
    Accept => [qw{application/json}],
  );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

OokOok::Controller::Theme - Catalyst Controller

=head1 DESCRIPTION

Provides the REST API for theme management used by the theme management
web pages. These should not be considered a general purpose API.

=head1 METHODS

=head1 AUTHOR

James Smith,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

