package OokOok::Controller::ThemeStyle;

use Moose;
use namespace::autoclean;

use OokOok::Collection::ThemeStyle;
use OokOok::Resource::ThemeStyle;

BEGIN {
  extends 'OokOok::Base::REST';
}

__PACKAGE__ -> config(
  map => {
  },
  default => 'text/html',
);

sub base :Chained('/') :PathPart('theme-style') :CaptureArgs(0) {
  my($self, $c) = @_;

  if($c -> stash -> {development} || $c -> stash -> {date}) {
    $c -> detach(qw/Controller::Root default/);
  }

  $c -> stash -> {development} = 1; # for use by resources/collections

  $c -> stash -> {collection} = OokOok::Collection::ThemeStyle -> new(c => $c);
}

1;

__END__
