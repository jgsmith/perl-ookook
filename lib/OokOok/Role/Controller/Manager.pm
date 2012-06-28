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

  # the management interface isn't versioned
  if($c -> stash -> {development} || $c -> stash -> {date}) {
    $c -> detach(qw/Controller::Root default/);
  }

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
    entity => $c -> stash -> {collection} -> GET
  );
}

sub things_POST {
  my($self, $c) = @_;

  my $thing = eval { $c -> stash -> {collection} -> POST($c -> req -> data) };
  my $object_name = $c -> stash -> {names} -> {thing};

  if($@) {
    $self -> status_bad_request(
      $c,
      message => "Unable to create $object_name: $@",
    );
  }
  elsif($thing) {
    my $json = $thing -> GET(1); # deep

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

#sub new_thing :Chained('things_base') :PathPart('new') :Args(0) { 
#  my($self, $c) = @_;
#
#  $c -> stash -> {projects} = [$c -> model("DB::Project") -> all];
#  $c -> stash -> {themes} = [$c -> model("DB::Theme") -> all];
#  $c -> stash -> {libraries} = [$c -> model("DB::Library") -> all];
#
#  my $form = HTML::FormFu->new({
#    action => $c -> req -> uri,
#    method => 'POST',
#    auto_fieldset => 1
#  });
#
#  $c -> stash -> {form} = $form;
#
#  my $object_name = $c -> stash -> {names} -> {thing};
#
#  $form -> load_config_file($c -> path_to('root', 'forms', 'new', $object_name . '.yml'));
#  if( $c -> req -> method eq 'POST') {
#    $form -> process($c -> req);
#  }
#
#  if( $form -> submitted_and_valid ) {
#    my $new_thing = $c -> model -> POST($c, $form -> params);
#    if($new_thing) {
#      my $json = $new_thing -> GET($c);
#      print STDERR "New object: ", JSON::encode_json($json), "\n";
#      $c -> response -> redirect( $json -> {url} );
#      $c -> detach;
#    }
#    else {
#      # unable to create project
#    }
#  }
#}

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
  my $resource_class = $self -> config -> {'current_model'};
  $resource_class =~ s{^DB::}{OokOok::Resource::};
  $c -> stash -> {$thing_name} = $resource_class -> new(
    c => $c,
    source => $thing
  );
}

sub thing :Chained('thing_base') :PathPart('') :Args(0) :ActionClass('REST') { }

sub thing_GET {
  my($self, $c) = @_;

  my $thing_name = $c -> stash -> {names} -> {thing};
  my $thing = $c -> stash -> {$thing_name};
  my $json = $thing -> GET(1);

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
  $thing = eval { $thing -> PUT($c -> req -> data) };

  if($@) {
    $self -> status_bad_request($c,
      message => "Unable to update resource: $@",
    );
  }
  else {
    $self -> status_ok($c,
      entity => $thing -> GET($c, 1)
    );
  }
}

sub thing_DELETE {
  my( $self, $c ) = @_;

  my $thing_name = $c -> stash -> {names} -> {thing};

  eval {
    $c -> stash -> {$thing_name} -> DELETE;
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
