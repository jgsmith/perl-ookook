use MooseX::Declare;

class OokOok::Collection::Project {
  use OokOok::Collection;

  method constrain_collection ($q, $deep) {
    if($self -> c -> user) {
      if($deep) {
        # we want all publicly accessible projects and projects managed by
        # this person
        $q = $q -> search({
          'board_members.user_id' => $self -> c -> user -> id,
        }, {
          join => { board => 'board_members' }
        });
      }
      else {
        # we only want projects managed/owned/edited by this person
        $q = $q -> search({
          'board_members.user_id' => $self -> c -> user -> id,
        }, {
          join => { board => 'board_members' }
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
    $board -> create_related('board_members', {
      user_id => $owner -> id,
      rank => 0,
    });

    $project -> source -> update({
      board_id => $board -> id
    });
    $project;
  }
}
