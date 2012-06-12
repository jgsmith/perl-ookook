package OokOok::Role::Controller::Manager;

use Moose::Role;
use Lingua::EN::Inflect qw(PL_N);
use MooseX::MethodAttributes::Role;
use namespace::autoclean;

sub status_service_unavailable {
  my($self, $c, %p) = @_;
  $c -> response -> status(503);
  $c->log->debug( "Status Service Unavailable: $p{message}" ) if $c -> debug;
  $c -> stash -> { $self -> {'stash_key'} } = {
    error => $p{message}
  };
  return 1;
}

sub _list_top_level_objects {
  my($self, $c) = @_;

  my $things = [];

  my $q = $c -> model;

  # TODO: now we can apply authorization constraints on $q

  my $thing = $c -> stash -> {names} -> {thing};
  my $method = "${thing}_to_json";
  while(my $thing = $q -> next) {
    push @$things, $self -> $method($c, $thing);
  }

  return $things;
}

###
### top-level Things handling (listing existing and creating new)
###

sub things_base :Chained('base') :PathPart('') :CaptureArgs(0) {
  my($self, $c) = @_;

  # the management interface isn't versioned
  if($c -> stash -> {development} || $c -> stash -> {date}) {
    $c -> detach(qw/Controller::Root default/);
  }

  $c -> stash(current_model_instance => $c -> model($self -> config -> {'current_model'}));
  my $thing = $self -> config -> {"singular"} || $c -> model -> result_source -> name;
  my $things = $self -> config -> {"plural"} || PL_N($thing);

  $c -> stash -> {names} = {
    thing => $thing,
    things => $things,
  };
}

sub things :Chained('things_base') :PathPart('') :Args(0) :ActionClass('REST') { }

sub things_GET {
  my($self, $c) = @_;

  my $things = $c -> stash -> {names} -> {things};

  $self -> status_ok(
    $c,
    entity => {
      $things => $self -> _list_top_level_objects($c)
    }
  );
}

sub things_POST {
  my($self, $c) = @_;

  my $object_name = $c -> stash -> {names} -> {thing};
  my $post_method = "${object_name}_from_json";
  my $get_method = "${object_name}_to_json";
  my $thing = eval { $self -> $post_method($c, $c -> req -> data) };
  #eval {
  #  $thing = $c->stash->{resultset}->new_result({});
  #  $thing -> insert;
  #  $ce = $thing -> current_edition;
  #  $ce -> update({
  #    name => $c->req->data->{name},
  #    description => $c->req->data->{description},
  #  });
  #};

  if($@) {
    $self -> status_bad_request(
      $c,
      message => "Unable to create $object_name: $@",
    );
  }
  else {
    my $json = $self -> $get_method($c, $thing, 1); # deep

    $self -> status_created($c,
      location => $json -> {url},
      entity => $json,
    );
  }
}

sub do_OPTIONS {
  my($self, $c, %headers) = @_;
  $c -> response -> status(200);
  $c -> response -> headers -> header(%headers);
  $c -> response -> body('');
  $c -> response -> content_length(0);
  $c -> response -> content_type("text/plain");
  $c -> detach();
}

sub things_OPTIONS {
  my($self, $c) = @_;

  $self -> do_OPTIONS( $c,
    Allow => [qw/GET OPTIONS POST/],
    Accept => [qw{application/json}],
  );
}

###
### individual Thing handling
###

sub thing_base :Chained('things_base') :PathPart('') :CaptureArgs(1) {
  my($self, $c, $uuid) = @_;

  my $q = $c -> model -> search({ uuid => $uuid }, { rows => 1 });
  if($self -> can("constrain_thing_search")) {
    $q = $self -> constrain_thing_search($c, $q);
  }
  my $thing = $q -> first;

  if(!$thing) {
    $self -> status_not_found($c,
      message => "Resource not found"
    );
    $c -> detach;
  }
  my $thing_name = $c -> stash -> {names} -> {thing};
  $c -> stash -> {$thing_name} = $thing;
  if($thing -> can('editions') && $thing -> can('current_edition')) {
    my $edition_name = $thing -> editions -> result_source -> name;
    $c -> stash -> {$edition_name} = $thing -> current_edition;
    $c -> stash -> {names} -> {edition} = $edition_name;
  }
  print STDERR "stash keys: ", join(", ", sort keys %{$c->stash}), "\n";
}

sub thing :Chained('thing_base') :PathPart('') :Args(0) :ActionClass('REST') { }

sub thing_GET {
  my($self, $c) = @_;

  my $thing_name = $c -> stash -> {names} -> {thing};
  my $thing = $c -> stash -> {$thing_name};
  my $method = "${thing_name}_to_json";
  my $json = $self -> $method($c, $thing, 1);

  print STDERR "Json: ", JSON::encode_json($json), "\n";

  $self -> status_ok(
    $c,
    entity => $json,
  );
}

sub thing_PUT {
  my($self, $c) = @_;

  my $thing_name = $c -> stash -> {names} -> {thing};
  my $thing = $c -> stash -> {$thing_name};
  my $put_method = "update_${thing_name}";
  my $get_method = "${thing_name}_to_json";
  $thing = eval { $self -> $put_method($c, $thing, $c -> req -> data) };

  if($@) {
    $self -> status_bad_request($c,
      message => "Unable to update resource: $@",
    );
  }
  else {
    $self -> status_ok($c,
      entity => $self -> $get_method($c, $thing, 1)
    );
  }
}

sub thing_DELETE {
  my( $self, $c ) = @_;

  my $thing_name = $c -> stash -> {names} -> {thing};

  eval {
    $c -> stash -> {$thing_name} -> delete;
  };

  $self -> status_no_content($c);
}

sub thing_OPTIONS {
  my($self, $c) = @_;

  $self -> do_OPTIONS($c,
    Allow => [qw/GET OPTIONS PUT DELETE/],
    Accept => [qw{application/json}],
  );
}

1;

__END__
