package OokOok::Controller::Theme;

use Moose;
use namespace::autoclean;

use JSON;

use OokOok::Collection::Theme;

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

sub layouts :Chained('thing_base') :PathPart('layout') :Args(0) :ActionClass('REST') { 
  my($self, $c) = @_;

  $c -> stash -> {collection} = OokOok::Collection::ThemeLayout -> new(c => $c);
}

sub layouts_GET { shift -> collection_GET }
sub layouts_POST { shift -> collection_POST }

sub layouts_OPTIONS {
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

