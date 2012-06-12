package OokOok::Role::Controller::HasPages;

use Moose::Role;
use MooseX::MethodAttributes::Role;
use namespace::autoclean;

sub pages :Chained('thing_base') :PathPart('page') :Args(0) :ActionClass('REST') { }

sub pages_GET {
  my($self, $c) = @_;

  my $q = $c -> model("DB::Page");

  if($self -> can("scope_pages")) {
    $q = $self -> scope_pages($c, $q);
  }

  my(%pages, $uuid);

  while(my $p = $q -> next) {
    $uuid = $p -> uuid;
    if($pages{$uuid}) {
      # we assume a higher id is a more recent version
      if($p -> id > $pages{$uuid} -> id) {
        $pages{$uuid} = $p;
      }
    }
    else {
      $pages{$uuid} = $p;
    }
  }

  my $controller = $c -> controller("Page");
  $self -> status_ok($c,
    entity => {
      pages => [ map { $controller -> page_to_json($c, $_) } values %pages ]
    }
  );
}

sub pages_POST {
  my($self, $c) = @_;

  my $controller = $c -> controller("Page");
  my $page = eval { $controller -> page_from_json($c, $c -> req -> data) };
  if($@) {
    $self -> status_bad_request($c,
      message => "Unable to create page: $@"
    );
  }
  else {
    my $json = $controller -> page_to_json($c, $page, 1);
    $self -> status_created($c,
      location => $json->{url},
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
