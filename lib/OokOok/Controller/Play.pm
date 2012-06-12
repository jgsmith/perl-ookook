package OokOok::Controller::Play;
use Moose;
use namespace::autoclean;

BEGIN { 
  extends 'Catalyst::Controller::REST'; 
  with 'OokOok::Role::Controller::Player';
}

__PACKAGE__ -> config(
  current_model => 'DB::Library',
);

use feature qw(switch);

=head1 NAME

OokOok::Controller::Play - Catalyst Controller

=head1 DESCRIPTION

Provides access to library functions via a REST interface.

=head1 METHODS

=cut


=head2 index

=cut

sub base :Chained('/') :PathPart('p') :CaptureArgs(0) { }

# paths: /p/.../$library/(function|...)/(function-uuid)/(mode)/
#        /p/.../$library/session/(session-uuid)
#
# how do we pipeline?
#

sub session_base :Chained('play_base') :PathPart('session') :CaptureArgs(1) {
  my($self, $c, $uuid) = @_;

  my $session = $c -> model("DB::FunctionSession") -> find({ uuid => $uuid });
  if(!$session || $session -> function -> library_edition -> library != $c -> stash -> {library}) {
    $c -> detach(qw/Controller::Root default/);
  }
  $c -> stash -> {function_session} = $session;
}

sub session :Chained('session_base') :PathPart('') :Args(0) :ActionClass('REST') { }

# provide status information. If finished, provide link to results.
# if mapping, results should be available asap. If reducing, then after
# final input data is provided.
#
# {
#   count => # of results
#   urls => { ... } patterns for forming result urls
#   status => 'Running'|'Finished'|'Error'
#   errors => ... (if stats = 'Error')
# }
#
sub session_GET {
  my($self, $c) = @_;

  my $session = $c -> stash -> {function_session};

  my $json = {};

  if($session -> has_errors) {
    $json -> {status} = 'Error';
    $json -> {errors} = $session -> errors;
  }
  else {
    if($session -> is_finished) {
      $json -> {status} = 'Finished';
    }
    else {
      $json -> {status} = 'Running';
    }
    $json -> {count} = $session -> results -> count;
    $json -> {urls} = {
        result_pattern => $c -> req -> uri . '/result/{index}',
        result_set_pattern => $c -> req -> uri . '/result/{first}-{last}',
        all_results => $c -> req -> uri . '/result',
    };
  }
  $self -> status_ok($c,
    entity => $json
  );
}

# feed data to process
sub session_POST {
  my($self, $c) = @_;

  my $session = $c -> stash -> {function_session};

  my $json = $c -> req -> data;
  my $status;

  if($json -> {params}) {
    $session -> add_params($json);
  }
  elsif($json -> {done}) {
    $session -> finish;
  }
  $self -> status_accepted($c,
    location => $c -> req -> uri,
    entity => {
      status => "queued",
    },
  );
}

# remove process - closes everything and deletes any results - only use
# if finished with the process and you've retrieved your results
sub session_DELETE {
  my($self, $c) = @_;

  my $session = $c -> stash -> {function_session};

  $session -> clean_up; # finishes and then deletes itself
  $self -> status_accepted($c,
    entity => {
      status => "queued",
    },
  );
}

sub session_OPTIONS {
}

# returns all of the results
sub results :Chained('session_base') :PathPart('result') :Args(0) :ActionClass('REST') { }

sub results_GET {
  my($self, $c) = @_;

}

# returns the specified result
sub result :Chained('session') :PathPart('result') :CaptureArgs(1) :ActionClass('REST') {
  my($self, $c, $index) = @_;

  if($index =~ m{^\d+$}) {
    $c -> stash -> {result_index_start} = $index;
    $c -> stash -> {result_index_end} = $index;
  }
  elsif($index =~ m{^(\d+)-(\d+)$}) {
    $c -> stash -> {result_index_start} = $1;
    $c -> stash -> {result_index_end} = $2;
  }
  else {
    $c -> detach(qw/Controller::Root default/);
  }
}

sub result_GET {
  my($self, $c) = @_;

}

sub result_OPTIONS {
  my($self, $c) = @_;
}

sub function :Chained('play_base') :PathPart('function') :Args(1) :ActionClass('REST') {
  my($self, $c, $uuid) = @_;

  my $function = $c -> stash -> {library_edition} -> function($uuid);
  if(!$function) {
    $c -> detach(qw/Controller::Root default/);
  }
  $c -> stash -> {function} = $function;
}

sub function_POST {
}

sub function_OPTIONS {
}

sub library :Chained('play_base') :PathPart('') :Args(0) :ActionClass('REST') { }

# explain the library functions, URLs, etc.
sub library_GET {
  
}

sub library_OPTIONS {
}

=head1 AUTHOR

James Smith,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
