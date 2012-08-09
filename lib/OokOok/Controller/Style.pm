package OokOok::Controller::Style;
use Moose;
use namespace::autoclean;

BEGIN {
  extends 'OokOok::Base::Player';
}

__PACKAGE__ -> config(
  map => {
    'text/css' => [ 'View', 'CSS' ],
  },
  default => 'text/css',
);

sub base :Chained('/') :PathPart('s') :CaptureArgs(0) {
  my($self, $c) = @_;

  $c -> stash -> {collection} = OokOok::Collection::Project -> new(
    c => $c,
  );
}

sub style_base :Chained('play_base') :PathPart('style') :CaptureArgs(1) {
  my($self, $c, $uuid) = @_;

  my $theme = $c -> stash -> {project} -> theme;
  my $style = $theme -> style($uuid);

  if(!$style) {
    $c -> detach(qw/Controller::Root default/);
  }

  $c -> stash -> {resource} = $style;
}

sub style :Chained('style_base') :PathPart('') :Args(0) :ActionClass('REST') { }

sub style_GET {
  my($self, $c) = @_;

  # TODO: cache compiled stylesheets
  $c -> stash -> {rendering} = $c -> stash -> {resource} -> render;
  $c -> stash -> {template} = 'style/style.tt2';
  $c -> forward( $c -> view('HTML') );
}

1;
