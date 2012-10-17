use OokOok::Declare;

# PODNAME: OokOok::Controller::Play

# ABSTRACT: Prototype interface for running algorithms

play_controller OokOok::Controller::Play {

  __PACKAGE__ -> config(
    map => {
      'text/html' => [ 'View', 'HTML' ],
    },
    default => 'text/html',
  );

  under '/' {
    action base as 'p' {
      $ctx -> stash -> {collection} = OokOok::Collection::Library -> new(
        c => $ctx
      );
    }
  }

  under play_base {
    action session_base ($uuid) as 'session' {
      my $session = $ctx -> model("DB::FunctionSession") 
                         -> find({ uuid => $uuid });
      if(!$session || $session -> function -> library_edition -> library != $ctx -> stash -> {library}) {
        $ctx -> detach(qw/Controller::Root default/);
      }
      $ctx -> stash -> {function_session} = $session;
    }

    final action function ($uuid) as 'function' isa REST {
      my $function = $ctx -> stash -> {library_edition} -> function($uuid);
      if(!$function) {
        $ctx -> detach(qw/Controller::Root default/);
      }
      $ctx -> stash -> {function} = $function;
    }
  }

  under session_base {
    final action session as '' isa REST;
    final action results as 'result' isa REST;
  }

  under session {
    final action result ($index) as 'result' isa REST {
      if($index =~ m{^\d+$}) {
        $ctx -> stash -> {result_index_start} = $index;
        $ctx -> stash -> {result_index_end} = $index;
      }
      elsif($index =~ m{^(\d+)-(\d+)$}) {
        $ctx -> stash -> {result_index_start} = $1;
        $ctx -> stash -> {result_index_end} = $2;
      }
      else {
        $ctx -> detach(qw/Controller::Root default/);
      }
    }
  }

  method session_GET ($ctx) {
    my $session = $ctx -> stash -> {function_session};

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
        result_pattern => $ctx -> req -> uri . '/result/{index}',
        result_set_pattern => $ctx -> req -> uri . '/result/{first}-{last}',
        all_results => $ctx -> req -> uri . '/result',
      };
    }
    $self -> status_ok($ctx,
      entity => $json
    );
  }

  # feed data to process
  method session_POST ($ctx) {
    my $session = $ctx -> stash -> {function_session};

    my $json = $ctx -> req -> data;
    my $status;

    if($json -> {params}) {
      $session -> add_params($json);
    }
    elsif($json -> {done}) {
      $session -> finish;
    }
    $self -> status_accepted($ctx,
      location => $ctx -> req -> uri,
      entity => {
        status => "queued",
      },
    );
  }

  # remove process - closes everything and deletes any results - only use
  # if finished with the process and you've retrieved your results
  method session_DELETE ($ctx) {
    my $session = $ctx -> stash -> {function_session};

    $session -> clean_up; # finishes and then deletes itself
    $self -> status_accepted($ctx,
      entity => {
        status => "queued",
      },
    );
  }

  method session_OPTIONS ($ctx) {
  }

  # returns all of the results

  method results_GET ($ctx) {
  
  }

  method result_GET ($ctx) {

  }

  method result_OPTIONS ($ctx) {

  }

  method function_POST {
  }

  method function_OPTIONS {
  }
}
