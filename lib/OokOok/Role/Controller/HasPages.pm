package OokOok::Role::Controller::HasPages;

use Moose::Role;
use MooseX::MethodAttributes::Role;
use namespace::autoclean;

use OokOok::Collection::Page;

sub pages :Chained('thing_base') :PathPart('page') :Args(0) :ActionClass('REST') { 
  my($self, $c) = @_;

  my $collection = OokOok::Collection::Page -> new(c => $c);
  $c -> stash -> {collection} = $collection;
}

sub pages_GET {
  my($self, $c) = @_;

  $self -> status_ok($c,
    entity => $c -> stash -> {collection} -> _GET
  );
}

sub pages_POST {
  my($self, $c) = @_;

  my $collection = OokOok::Collection::Page -> new(c => $c);

  my $resource = eval { $c -> stash -> {collection} -> _POST($c -> req -> data) };
  if($@) {
    $self -> status_bad_request($c,
      message => "Unable to create page: $@"
    );
  }
  else {
    $c -> stash -> {resource} = $resource;
    my $json = $resource -> _GET(1);
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
