package OokOok::Controller::Library;

use Moose;
use namespace::autoclean;

use OokOok::Collection::Library;

BEGIN {
  extends 'OokOok::Base::REST';
}

__PACKAGE__ -> config(
  map => {
  },
  default => 'text/html',
);

sub base :Chained('/') :PathPart('library') :CaptureArgs(0) { 
  my($self, $c) = @_;

  if($c -> stash -> {development} || $c -> stash -> {date}) {
    $c -> detach(qw/Controller::Root default/);
  }

  $c -> stash -> {development} = 1; # for use by resources/collections

  $c -> stash -> {collection} = OokOok::Collection::Library -> new(c => $c);
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

