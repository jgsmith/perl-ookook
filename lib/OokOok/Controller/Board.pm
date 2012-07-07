package OokOok::Controller::Board;

use Moose;
use namespace::autoclean;

use OokOok::Collection::Board;
use OokOok::Resource::Board;

BEGIN {
  extends 'OokOok::Base::ResourceController';
}

__PACKAGE__ -> config(
  map => {
  },
  default => 'text/html',
);

sub base :Chained('/') :PathPart('board') :CaptureArgs(0) {
  my($self, $c) = @_;

  $c -> stash -> {collection} = OokOok::Collection::Board -> new(c => $c);
}

1;
