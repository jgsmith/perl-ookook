package OokOok::Role::Controller::HasEditions;

use Moose::Role;
use MooseX::MethodAttributes::Role;
use namespace::autoclean;

sub edition :Chained('thing_base') :PathPart('edition') :Args(0) :ActionClass('REST') { 
  my($self, $c) = @_;
  my $thing_name = $c -> stash -> {names} -> {thing};
  my $thing = $c -> stash -> {$thing_name};
  $c -> stash -> {edition} = $thing -> edition;
}

sub edition_GET {
  my($self, $c) = @_;

  my $edition = $c -> stash -> {edition};

  $self -> status_ok($c,
    entity => $edition -> GET(1)
  );
}

sub edition_POST {
  my($self, $c) = @_;

  my $thing_name = $c -> stash -> {names} -> {thing};
  my $edition = $c -> stash -> {edition};

  if($edition -> source -> created_on < DateTime->now) {
    $edition -> source -> close;
    my $edition = $c -> stash -> {$thing_name} -> edition;
    my $json = $edition -> GET(1);
    $self -> status_created($c,
      location => $json -> {_links} -> {self},
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

  eval {
    $c -> stash -> {edition} -> DELETE;
  };

  if($@) {
    $self -> status_forbidden($c, message => "unable to clear edition: $@");
  }
  else {
    $self -> status_no_content($c);
  }
}

1;

__END__
