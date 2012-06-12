package OokOok::Role::Controller::Player;

use Moose::Role;
use MooseX::MethodAttributes::Role;
use namespace::autoclean;

sub play_base :Chained('base') :PathPart('') :CaptureArgs(1) {
  my($self, $c, $uuid) = @_;

  my $date;
  $c -> stash(current_model_instance => $c -> model($self -> config -> {'current_model'}));

  my $thing_name = $c -> model -> result_source -> name;
  my $edition_name;

  my $thing = $c -> model -> find({ uuid => $uuid });
  if(!$thing) {
    $c -> detach(qw/Controller::Root default/);
  }
  $edition_name = $thing -> editions -> result_source -> name;
  $c -> stash($thing_name => $thing);

  if($c -> stash -> {development}) {
    # development version
    $c -> stash($edition_name => $thing -> current_edition);
    $date = undef;
  }
  elsif($date = $c -> stash -> {date}) {
    $c -> stash($edition_name => $thing -> edition_for_date($date));
  }
  else {
    $date = DateTime -> now;
    $c -> stash($edition_name => $thing -> edition_for_date($date));
  }

  if(!$c -> stash -> {$edition_name}) {
    $c -> detach(qw/Controller::Root default/);
  }
}

1;

__END__
