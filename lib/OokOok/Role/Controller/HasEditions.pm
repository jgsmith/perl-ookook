package OokOok::Role::Controller::HasEditions;

use Moose::Role;
use MooseX::MethodAttributes::Role;
use namespace::autoclean;

sub edition :Chained('thing_base') :PathPart('edition') :Args(0) :ActionClass('REST') { }

sub edition_GET {
  my($self, $c) = @_;

  my $thing_name = $c -> stash -> {names} -> {thing};
  my $edition_name = $c -> stash -> {names} -> {edition};
  my $edition = $c -> stash -> {$edition_name};
  my $method = "${edition_name}_to_json";

  $self -> status_ok($c,
    entity => $self -> $method($c, $edition, 1)
  );
}

sub edition_POST {
  my($self, $c) = @_;

  my $thing_name = $c -> stash -> {names} -> {thing};
  my $edition_name = $c -> stash -> {names} -> {edition};
  my $edition = $c -> stash -> {$edition_name};
  my $method = "${edition_name}_to_json";

  if($edition -> created_on < DateTime->now) {
    $edition -> freeze;
    my $edition = $c -> stash -> {$thing_name} -> current_edition;
    my $json = $self -> $method($c, $edition, 1);
    $self -> status_created($c,
      location => $json -> {url},
      entity => $json,
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

  my $thing_name = $c -> stash -> {names} -> {thing};
  my $edition_name = $c -> stash -> {names} -> {edition};
  eval {
    $c -> stash -> {$edition_name} -> delete;
  };

  if($@) {
    $self -> status_forbidden($c, entity => { message => 'unable to clear edition' });
  }
  else {
    $self -> status_no_content($c);
  }
}

1;

__END__
