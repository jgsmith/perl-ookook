package OokOok::Role::Controller::HasPages;

use Moose::Role;
use MooseX::MethodAttributes::Role;
use namespace::autoclean;

sub pages :Chained('thing_base') :PathPart('page') :Args(0) :ActionClass('REST') { }

sub pages_GET {
  my($self, $c) = @_;

  my $resource = OokOok::Collection::Page -> new(c => $c);

  $self -> status_ok($c,
    entity => $resource -> GET
  );
}

sub pages_POST {
  my($self, $c) = @_;

  my $resource = OokOok::Collection::Page -> new(c => $c);

  my $page = eval { $resource -> POST($c -> req -> data) };
  if($@) {
    $self -> status_bad_request($c,
      message => "Unable to create page: $@"
    );
  }
  else {
    my $json = $page -> GET(1);
    $self -> status_created($c,
      location => $json->{_links} -> {self},
      entity => $json,
    );
  }
}

sub pages_OPTIONS {
  my($self, $c) = @_;

  $self -> do_OPTIONS($c,
    Allow => [qw/GET OPTIONS PUT/],
    Accept => [qw{application/json}],
  );
}

1;
