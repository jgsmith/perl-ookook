use OokOok::Declare;

# PODNAME: OokOok::Controller::Admin::Board

# ABSTRACT: Controller to administer boards

admin_controller OokOok::Controller::Admin::Board {

  use DateTime;

  action base under '/' as 'admin/board';

  under base {
    action board_base (Str $uuid) as '' {
      my $resource = OokOok::Collection::Board->new(c => $ctx)
                                              ->resource($uuid);
      if(!$resource) {
        $ctx -> detach(qw/Controller::Root default/);
      }
      $ctx -> stash -> {board} = $resource;
    }
  }

  under base {

    final action index as '' {
      $ctx -> stash -> {boards} = [
        OokOok::Collection::Board -> new(c => $ctx) -> resources
      ];
      $ctx -> stash -> {template} = "/admin/top/boards";
    }

  }

  under board_base {
    final action board_view as '' {
      my $uuid = $ctx -> stash -> {board} -> id;
      $ctx -> response -> redirect(
        $ctx -> uri_for("/admin/board/$uuid/member")
      );
    }

    action board_members_base as 'member';

    action board_applicants_base as 'applicant';

    action settings;
  }

  under board_members_base {
    action board_member_base ($uuid) as '' {
      my $membership = $ctx -> stash -> {board} -> member($uuid);
      if(!$membership) {
        $ctx -> detach(qw/Controller::Root default/);
      }
      $ctx -> stash -> {board_member} = $membership;
    }
  }

  under board_applicants_base {
    action board_applicant_base ($uuid) as '' {
      my $application = $ctx -> stash -> {board} -> application($uuid);
      if(!$application) {
        $ctx -> detach(qw/Controller::Root default/);
      }
      $ctx -> stash -> {board_application} = $application;
    }
  }

  under settings {
    final action board_settings as '' {
      $ctx -> stash -> {template} = "/admin/board/settings/settings";
    }

    final action board_edit as 'edit' {
      my $board = $ctx -> stash -> {board};

      if($ctx -> request -> method eq 'POST') {
        my $res = $self -> PUT($ctx, $board, $ctx -> request -> params);
        if($res) {
          $ctx -> response -> redirect(
            $ctx -> uri_for( "/admin/board/" . $board -> id . "/settings" )
          );
        }
      }
      else {
        $ctx -> stash -> {form_data} = {
          name => $board -> name,
          description => $board -> description,
        };
      }
      $ctx -> stash -> {template} = "/admin/board/settings/settings/edit";
    }
  }

# members (have rank)
# ranks (rank has permisions)
# 


# for now, ranks below zero are for applicants - we may change that
# later

  under board_members_base {

    final action board_members as '' {
      $ctx -> stash -> {board_members} = [
        sort {
          $a->rank <=> $b->rank ||
          $a->user->name cmp $b->user->name
        } grep {
          $_ -> rank >= 0
        } @{$ctx -> stash -> {board} -> board_members||[]}
      ];
      my %ranks = map { $_->position => $_ } @{$ctx -> stash -> {board} -> board_ranks};
      $ctx -> stash -> {ranks} = \%ranks;
      $ctx -> stash -> {template} = "/admin/board/membership/member";
    }

  }

  under board_member_base {

=over

    final action move_up {
      my $board = $ctx -> stash -> {board};
      if($ctx -> request -> method eq 'POST') {
        my $own_membership = $board -> member(
          $ctx -> user -> uuid
        );
        my $member = $ctx -> stash -> {board_member};
        if($own_membership &&
           $own_membership -> rank < $member->rank-1) {
          # now can the logged in user manage a member's rank?
          if(1) {
            my $res = $self -> PUT($ctx, $member, {
              rank = $member -> rank - 1
            });
          }
        }
      }
      $ctx -> response -> redirect(
        $ctx -> uri_for( "/admin/board/" . $board -> id . "/member" )
      );
    }


    final action move_down {
      my $board = $ctx -> stash -> {board};
      if($ctx -> request -> method eq 'POST') {
        my $own_membership = $board -> member(
          $ctx -> user -> uuid
        );
        my $member = $ctx -> stash -> {board_member};
        if($own_membership &&
           $own_membership -> rank < $member->rank &&
           $member->rank < $ctx -> stash -> {board} -> maximum_rank) {
          # now can the logged in user manage a member's rank?
          if(1) {
            my $res = $self -> PUT($ctx, $member, {
              rank = $member -> rank + 1
            });
          }
        }
      }
      $ctx -> response -> redirect(
        $ctx -> uri_for( "/admin/board/" . $board -> id . "/member" )
      );
    }

=cut

    final action dismiss {
      my $board = $ctx -> stash -> {board};
      if($ctx -> request -> method eq 'POST') {
        my $own_membership = $board -> member(
          $ctx -> user -> uuid
        );
        my $member = $ctx -> stash -> {board_member};
        if($own_membership &&
           $own_membership -> rank < $member->rank) {
          # now can the logged in user dismiss a member?
          if(1) {
          }
        }
      }
      $ctx -> response -> redirect(
        $ctx -> uri_for( "/admin/board/" . $board -> id . "/member" )
      );
    }
  }

  under board_applicants_base {
    final action board_applicants as '' {
      $ctx -> stash -> {board_members} = [
        sort {
          $a->rank <=> $b->rank ||
          $a->user->name cmp $b->user->name
        } grep {
          $_ -> rank < 0
        } @{$ctx -> stash -> {board} -> board_applicants||[]}
      ];
      $ctx -> stash -> {template} = "/admin/board/membership/applicant";
    }
  }

  under board_base {
    final action board_ranks as 'rank' {
      $ctx -> stash -> {ranks} = [
        sort {
          $a -> position <=> $b -> position
        } @{$ctx -> stash -> {board} -> board_ranks || []}
      ];
      $ctx -> stash -> {template} = "/admin/board/settings/rank";
    }

    final action board_application as 'application' {
      my $board = $ctx -> stash -> {board};

      if($ctx -> request -> method eq 'POST') {
        my $res = $self -> PUT($ctx, $board, {
          application => $ctx -> request -> params -> {application}
        });
        if($res) {
          $ctx -> response -> redirect(
            $ctx -> uri_for( "/admin/board/" . $board->id . "/settings" )
          );
        }
      }
      else {
        $ctx -> stash -> {form_data} = {
           application => $board -> application
        };
      }
      $ctx -> stash -> {template} = "/admin/board/settings/settings/application";
    }

  }
}
