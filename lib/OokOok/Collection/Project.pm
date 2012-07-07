package OokOok::Collection::Project;

use OokOok::Collection;
use namespace::autoclean;

sub constrain_collection {
  my($self, $q, $deep) = @_;

  if($self -> c -> user) {
    if($deep) {
      # we want all publicly accessible projects and projects managed by
      # this person
      $q = $q -> search({
        'board_members.user_id' => $self -> c -> user -> id,
      }, {
        join => { board => { board_ranks => 'board_members' } }
      });
    }
    else {
      # we only want projects managed/owned/edited by this person
      $q = $q -> search({
        'board_members.user_id' => $self -> c -> user -> id,
      }, {
        join => { board => { board_ranks => 'board_members' } }
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

sub POST {
  my($self, $json) = @_;

  my $owner = $self -> c -> user;

  if(!$owner) {
    die "Unable to create a project without an owner";
  }

  my $values = $self -> verify($json);

  my $board = $self -> c -> model('DB::Board') -> new_result({
    name => $values->{name} . ' Management',
  });
  $board -> insert;

  my $rank = $board -> create_related('board_ranks', {
    name => 'Administrator',
    position => 0,
    is_editor => 1,
  });
  $rank -> create_related('board_members', {
    user_id => $owner -> id,
  });

  my $project = $self -> c -> model('DB::Project') -> new_result({
    board_id => $board -> id,
  });
  $project -> insert;
  $project -> current_edition -> update($json);
  OokOok::Resource::Project -> new(
    source => $project,
    c => $self -> c
  );
}


1;

__END__
