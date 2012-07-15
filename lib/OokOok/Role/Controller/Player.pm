package OokOok::Role::Controller::Player;

use Moose::Role;
use MooseX::MethodAttributes::Role;
use namespace::autoclean;

sub play_base :Chained('base') :PathPart('') :CaptureArgs(1) {
  my($self, $c, $uuid) = @_;

  #my $date;
  $c -> stash(current_model_instance => $c -> model($self -> config -> {'current_model'}));

  my $thing_name = $c -> model -> result_source -> name;

  my $collection_name = $self -> config -> {'collection_resource_name'};
  $c -> stash -> {$thing_name} = $collection_name -> new(
    c => $c
  ) -> resource($uuid);

  if(!$c -> stash -> {$thing_name}) {
    $c -> detach(qw/Controller::Root default/);
  }
}

sub end : ActionClass('RenderView') {}

1;

__END__
