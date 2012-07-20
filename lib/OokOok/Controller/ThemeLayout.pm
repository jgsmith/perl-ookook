package OokOok::Controller::ThemeLayout;

use Moose;
use namespace::autoclean;

use OokOok::Collection::ThemeLayout;
use OokOok::Resource::ThemeLayout;

BEGIN {
  extends 'OokOok::Base::REST';
}

__PACKAGE__ -> config(
  map => {
  },
  default => 'text/html',
);

sub base :Chained('/') :PathPart('theme-layout') :CaptureArgs(0) {
  my($self, $c) = @_;

  if($c -> stash -> {development} || $c -> stash -> {date}) {
    $c -> detach(qw/Controller::Root default/);
  }

  $c -> stash -> {development} = 1; # for use by resources/collections

  $c -> stash -> {collection} = OokOok::Collection::ThemeLayout -> new(c => $c);
}

1;

__END__
