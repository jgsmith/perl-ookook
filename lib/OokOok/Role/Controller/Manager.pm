package OokOok::Role::Controller::Manager;

use Moose::Role;
use Lingua::EN::Inflect qw(PL_N);
use MooseX::MethodAttributes::Role;
#use HTML::FormFu;
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

###
### top-level Things handling (listing existing and creating new)
###

sub things_base :Chained('base') :PathPart('') :CaptureArgs(0) {
  my($self, $c) = @_;

  # the management interface isn't versioned up to this point in the
  # execution path
  if($c -> stash -> {development} || $c -> stash -> {date}) {
    $c -> detach(qw/Controller::Root default/);
  }

  $c -> stash -> {development} = 1; # for use by resources/collections

  $c -> stash(current_model_instance => $c -> model($self -> config -> {'current_model'}));
  my $thing = $self -> config -> {"singular"} || $c -> model -> result_source -> name;
  my $things = $self -> config -> {"plural"} || PL_N($thing);

  $c -> stash(collection => $self -> config -> {'collection_resource_class'} -> new(c => $c));

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
    entity => $c -> stash -> {collection} -> _GET
  );
}

sub things_POST {
  my($self, $c) = @_;

  my $thing = eval { $c -> stash -> {collection} -> _POST($c -> req -> data) };
  my $object_name = $c -> stash -> {names} -> {thing};

  if($@) {
    $self -> status_bad_request(
      $c,
      message => "Unable to create $object_name: $@",
    );
  }
  elsif($thing) {
    my $json = $thing -> _GET(1); # deep

    $self -> status_created($c,
      location => $json -> {_links} -> {self},
      entity => $json,
    );
  }
  else {
    $self -> status_bad_request($c,
      message => "Unable to create $object_name",
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
  $c -> stash -> {$thing_name} = $c -> stash -> {collection} -> resource($uuid);
}

sub thing :Chained('thing_base') :PathPart('') :Args(0) :ActionClass('REST') { }

sub thing_GET {
  my($self, $c) = @_;

  my $thing_name = $c -> stash -> {names} -> {thing};
  my $thing = $c -> stash -> {$thing_name};
  my $json = $thing -> _GET(1);

  # need to restrict to the columns we need -- uuid and name
  $c -> stash -> {projects} = [$c -> model("DB::Project") -> all];
  $c -> stash -> {themes} = [$c -> model("DB::Theme") -> all];
  $c -> stash -> {libraries} = [$c -> model("DB::Library") -> all];

  $self -> status_ok(
    $c,
    entity => $json,
  );
}

sub thing_PUT {
  my($self, $c) = @_;

  my $thing_name = $c -> stash -> {names} -> {thing};
  my $thing = $c -> stash -> {$thing_name};
  $thing = eval { $thing -> _PUT($c -> req -> data) };

  if($@) {
    $self -> status_bad_request($c,
      message => "Unable to update resource: $@",
    );
  }
  else {
    $self -> status_ok($c,
      entity => $thing -> _GET($c, 1)
    );
  }
}

sub thing_DELETE {
  my( $self, $c ) = @_;

  my $thing_name = $c -> stash -> {names} -> {thing};

  eval {
    $c -> stash -> {$thing_name} -> _DELETE;
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
