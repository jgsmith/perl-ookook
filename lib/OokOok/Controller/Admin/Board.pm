use CatalystX::Declare;

controller OokOok::Controller::Admin::Board
   extends OokOok::Base::Admin
{

  use DateTime;

  use OokOok::Collection::Board;
  use OokOok::Resource::Board;

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

    final action board_settings as 'settings' {
      $ctx -> stash -> {template} = "/admin/board/settings/settings";
    }

    final action board_edit as 'settings/edit' {
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


# members (have rank)
# ranks (rank has permisions)
# 


# for now, ranks below zero are for applicants - we may change that
# later

    final action board_members as 'member' {
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

    final action board_applicants as 'applicant' {
      $ctx -> stash -> {board_members} = [
        sort {
          $a->rank <=> $b->rank ||
          $a->user->name cmp $b->user->name
        } grep {
          $_ -> rank < 0
        } @{$ctx -> stash -> {board} -> board_members||[]}
      ];
      $ctx -> stash -> {template} = "/admin/board/membership/applicant";
    }

    final action board_ranks as 'rank' {
      $ctx -> stash -> {ranks} = [
        sort {
          $a -> position <=> $b -> position
        } @{$ctx -> stash -> {board} -> board_ranks || []}
      ];
      $ctx -> stash -> {template} = "/admin/board/settings/rank";
    }
  }
}
