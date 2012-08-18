package OokOok::Controller::Admin::Board;

use Moose;
use namespace::autoclean;

use DateTime;

use OokOok::Collection::Board;
use OokOok::Resource::Board;

BEGIN {
  extends 'OokOok::Base::Admin';
}

sub base :Chained('/') :PathPart('admin/board') :CaptureArgs(0) { }

sub index :Chained('base') :PathPart('') :Args(0) {
  my($self, $c) = @_;

  $c -> stash -> {boards} = [
    OokOok::Collection::Board -> new(c => $c) -> resources
  ];
  $c -> stash -> {template} = "/admin/top/boards";
}

# we don't allow board creation, so no
# sub board_new ...

sub board_base :Chained('base') :PathPart('') :CaptureArgs(1) {
  my($self, $c, $uuid) = @_;

  my $resource = OokOok::Collection::Board->new(c => $c) ->
                 resource($uuid);

  if(!$resource) {
    $c -> detach(qw/Controller::Root default/);
  }
  $c -> stash -> {board} = $resource;
}

sub board_view :Chained('board_base') :PathPart('') :Args(0) {
  my($self, $c) = @_;

  my $id = $c -> stash -> {board} -> id;
  $c -> response -> redirect($c -> uri_for("/admin/board/$id/member"));
}

sub board_settings :Chained('board_base') :PathPart('settings') :Args(0) {
  my($self, $c) = @_;

  $c -> stash -> {template} = "/admin/board/settings/settings";
}

sub board_edit :Chained('board_base') :PathPart('settings/edit') :Args(0) {
  my($self, $c) = @_;

  my $board = $c -> stash -> {board};

  if($c -> request -> method eq 'POST') {
    my $res = $self -> PUT($c, $board, $c -> request -> params);
    if($res) {
      $c -> response -> redirect(
        $c -> uri_for( "/admin/board/" . $board -> id . "/settings" )
      );
    }
  }
  else {
    $c -> stash -> {form_data} = {
      name => $board -> name,
      description => $board -> description,
    };
  }
  $c -> stash -> {template} = "/admin/board/settings/settings/edit";
}

# boards don't have editions...

# members (have rank)
# ranks (rank has permisions)
# 


# for now, ranks below zero are for applicants - we may change that
# later
sub board_members :Chained("board_base") :PathPart('member') :Args(0) {
  my($self, $c) = @_;

  $c -> stash -> {board_members} = [
    sort {
      $a->rank <=> $b->rank ||
      $a->user->name cmp $b->user->name
    } grep {
      $_ -> rank >= 0
    } @{$c -> stash -> {board} -> board_members||[]}
  ];
  my %ranks = map { $_->position => $_ } @{$c -> stash -> {board} -> board_ranks};
  $c -> stash -> {ranks} = \%ranks;
  $c -> stash -> {template} = "/admin/board/membership/member";
}

sub board_applicants :Chained("board_base") :PathPart('applicant') :Args(0) {
  my($self, $c) = @_;

  $c -> stash -> {board_members} = [
    sort {
      $a->rank <=> $b->rank ||
      $a->user->name cmp $b->user->name
    } grep {
      $_ -> rank < 0
    } @{$c -> stash -> {board} -> board_members||[]}
  ];
  $c -> stash -> {template} = "/admin/board/membership/applicant";
}

sub board_ranks :Chained("board_base") :PathPart('rank') :Args(0) {
  my($self, $c) = @_;

  $c -> stash -> {ranks} = [
    sort {
      $a -> position <=> $b -> position
    } @{$c -> stash -> {board} -> board_ranks || []}
  ];
  $c -> stash -> {template} = "/admin/board/settings/rank";
}

1;
