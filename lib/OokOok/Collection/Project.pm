use OokOok::Declare;

# PODNAME: OokOok::Collection::Project

# ABSTRACT: Project REST collection

collection OokOok::Collection::Project {

  method constrain_collection ($q, $deep) {
    if($self -> c -> user) {
      if($deep) {
        # we want all publicly accessible projects and projects managed by
        # this person
        $q = $q -> search({
          'board_members.user_id' => $self -> c -> user -> id,
        }, {
          join => { board => { 'board_ranks' => 'board_members' } }
        });
      }
      else {
        # we only want projects managed/owned/edited by this person
        $q = $q -> search({
          'board_members.user_id' => $self -> c -> user -> id,
        }, {
          join => { board => { 'board_ranks' => 'board_members' } }
        });
      }
    }
    else {
      # we only want projects with a publicly available edition
      $q = $q -> search({ 
          "editions.closed_on" => { '!=' => undef },
        }, {
          join => [qw/editions/],
        }
      );
    }

    $q;
  }

  method can_POST {
    defined $self -> c -> user;
  }

  method may_POST { 1; }

  # TODO: allow a project to be created and assigned to an existing board

  around POST (@rest) {
    my $owner = $self -> c -> user;

    if(!$owner) {
      die "Unable to create a project without an owner";
    }

    my $project = $self->$orig(@rest);

    my $board = $self -> c -> model('DB::Board') -> new_result({
      name => $project->name . ' Management',
    });
    $board -> insert;

    my $rank = $board -> create_related('board_ranks', {
      name => 'Administrator',
      position => 0,
    });
    $rank -> create_related('board_members', {
      user_id => $owner -> id,
    });

    $project -> source -> update({
      board_id => $board -> id
    });
    $project;
  }
}
