package OokOok::Role::Controller::Manager;

use Moose::Role;
use Lingua::EN::Inflect qw(PL_N);
use MooseX::MethodAttributes::Role;

#requires 'manager_base';

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

  my @things;

  my $q = $c -> stash -> {resultset};

  # TODO: now we can apply authorization constraints on $q

  for my $thing (sort { $b -> current_edition -> id <=> $a -> current_edition -> id } $q -> all) {
    my $ce = $thing -> current_edition;
    my $t = {
      name => $ce -> name,
      last_frozen_on => (map { defined($_) ? "".$_ : "" } $thing -> last_frozen_on),
      uuid => $thing -> uuid,
      description => $ce -> description,
    };

    push @things, $t;
  }

  return [@things];
}

###
### top-level Things handling (listing existing and creating new)
###

sub index :Chained('manager_base') :PathPart('') :Args(0) :ActionClass('REST') {
  my($self, $c) = @_;
  $c -> stash(resultset => $c -> model($self -> config -> {'model'}));
}

sub index_GET {
  my($self, $c) = @_;

  my $things = PL_N($c -> stash -> {resultset} -> result_source -> name);

  $self -> status_ok(
    $c,
    entity => {
      $things => $self -> _list_top_level_objects($c)
    }
  );
}

sub index_POST {
  my($self, $c) = @_;

  my($thing, $ce);
  my $object_name = $c -> stash -> {resultset} -> result_source -> name;
  eval {
    $thing = $c->stash->{resultset}->new_result({});
    $thing -> insert;
    $ce = $thing -> current_edition;
    $ce -> update({
      name => $c->req->data->{name},
      description => $c->req->data->{description},
    });
  };

  if($@) {
    $self -> status_bad_request(
      $c,
      message => "Unable to create object: $@",
    );
  }
  else {
    $self -> status_created(
      $c,
      location => $c -> uri_for('/'.$object_name) . '/' . $thing -> uuid,
      entity => {
        $object_name => {
          name => $ce -> name,
          description => $ce -> description,
          last_frozen_on => (map { defined($_) ? "".$_ : "" } $thing->last_frozen_on),
          uuid => $thing -> uuid,
        },
        PL_N($object_name) => $self -> _list_top_level_objects($c)
      }
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

sub index_OPTIONS {
  my($self, $c) = @_;

  $self -> do_OPTIONS( $c,
    Allow => [qw/GET OPTIONS POST/],
    Accept => [qw{application/json}],
  );
}

###
### individual Thing handling
###

sub base :Chained('manager_base') :PathPart('') :CaptureArgs(1) {
  my($self, $c, $uuid) = @_;

  $c -> stash(resultset => $c->model($self -> config -> {'model'}));

  my $thing;
  if($uuid =~ /^[-A-Za-z0-9_]{20}$/) {
    $thing = $c -> stash -> {resultset} -> find({ uuid => $uuid });
  }
  if(!$thing) {
    $self -> status_not_found($c,
      message => "Resource not found"
    );
    $c -> detach;
  }
  my $thing_name = $c -> stash -> {resultset} -> result_source -> name;
  my $edition_name = $thing -> editions -> result_source -> name;
  $c -> stash -> {$thing_name} = $thing;
  $c -> stash -> {$edition_name} = $thing -> current_edition;
}

sub thing :Chained('base') :PathPart('') :Args(0) :ActionClass('REST') { }

sub thing_GET {
  my($self, $c) = @_;

  my $thing_name = $c -> stash -> {resultset} -> result_source -> name;
  my $thing = $c -> stash -> {$thing_name};
  my $edition_name = $thing -> editions -> result_source -> name;
  my $ce = $c -> stash -> {$edition_name};

  my $data = {
    name => $ce -> name,
    uuid => $thing -> uuid,
    url => $c -> uri_for('/' . $thing_name) . '/' . $thing -> uuid,
    description => $ce -> description,
    editions => [
      map { +{
        frozen_on => (map { defined($_) ? "".$_ : "" } $_ -> frozen_on),
        created_on => (map { defined($_) ? "".$_ : "" } $_ -> created_on),
        name => $_ -> name,
        description => $_ -> description,
      } } $thing -> editions -> search({}, { order_by => 'id' }) -> all
    ],
  };

  $self -> status_ok(
    $c,
    entity => {
      $thing_name => $data
    }
  );
}

sub thing_PUT {
  my($self, $c) = @_;

  my $thing_name = $c -> stash -> {resultset} -> result_source -> name;
  my $thing = $c -> stash -> {$thing_name};
  my $edition_name = $thing -> editions -> result_source -> name;
  my $ce = $c -> stash -> {$edition_name};

  eval {
    my $updates = {
      name => $c -> req -> data -> {name},
      description => $c -> req -> data -> {description},
    };

    for (qw/name description/) {
      delete $updates->{$_} unless defined $updates->{$_};
    }

    $ce = $ce -> update($updates) if scalar(keys %$updates);
  };

  if($@) {
    $self -> status_bad_request(
      $c,
      message => "Unable to update resource: $@",
    );
  }
  else {
    my $data = {
      name => $ce->name,
      uuid => $thing -> uuid,
      url => $c->uri_for("/" . $thing_name) . '/' . $thing -> uuid,
      description => $ce -> description,
      editions => [
        map { +{
          frozen_on => (map { defined($_) ? "".$_ : "" } $_ -> frozen_on),
          created_on => (map { defined($_) ? "".$_ : "" } $_ -> created_on),
          name => $_ -> name,
          description => $_ -> description,
        } } $thing -> editions -> search({}, { order_by => 'id' }) -> all
      ],
    };
    $self -> status_ok(
      $c,
      entity => {
        $thing_name => $data
      }
    );
  }
}

sub thing_DELETE {
  my( $self, $c ) = @_;

  my $thing_name = $c -> stash -> {resultset} -> result_source -> name;

  eval {
    $c -> stash -> {$thing_name} -> delete;
  };

  if($@) {
    $self -> status_forbidden($c, entity => { message => 'unable to delete resource' });
  }
  else {
    $self -> status_ok($c, entity => { message => 'success' });
  }
}

sub thing_OPTIONS {
  my($self, $c) = @_;

  $self -> do_OPTIONS($c,
    Allow => [qw/GET OPTIONS PUT DELETE/],
    Accept => [qw{application/json}],
  );
}

###
### Edition handling
###

sub edition :Chained('base') :PathPart('edition') :Args(0) :ActionClass('REST') { }

sub edition_GET {
  my($self, $c) = @_;

  my $thing_name = $c -> stash -> {resultset} -> result_source -> name;
  my $edition_name = $c -> stash -> {$thing_name} -> editions -> result_source -> name;
  my $edition = $c -> stash -> {$edition_name};

  $self -> status_ok(
    $c,
    entity => {
      $edition_name => {
        created_on => "".$edition->created_on,
        description => $edition -> description,
        name => $edition -> name
      },
    }
  );
}

sub edition_POST {
  my($self, $c) = @_;

  my $thing_name = $c -> stash -> {resultset} -> result_source -> name;
  my $edition_name = $c -> stash -> {$thing_name} -> editions -> result_source -> name;
  my $edition = $c -> stash -> {$edition_name};

  if($edition -> created_on < DateTime->now) {
    $edition -> freeze;
    my $edition = $c -> stash -> {$thing_name} -> current_edition;
    $self -> status_ok(
      $c,
      entity => {
        $edition_name => {
          created_on => "".$edition->created_on,
          description => $edition -> description,
          name => $edition->name
        }
      }
    );
  }
  else {
    $self -> status_service_unavailable($c,
      message => "Previous working edition too recent"
    );
  }
}

sub edition_DELETE {
  my($self, $c) = @_;

  my $thing_name = $c -> stash -> {resultset} -> result_source -> name;
  my $edition_name = $c -> stash -> {$thing_name} -> editions -> result_source -> name;
  eval {
    $c -> stash -> {$edition_name} -> delete;
  };

  if($@) {
    $self -> status_forbidden($c, entity => { message => 'unable to clear edition' });
  }
  else {
    $self -> status_ok($c, entity => { message => 'success' });
  }
}

1;

__END__
