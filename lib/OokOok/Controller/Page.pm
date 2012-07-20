package OokOok::Controller::Page;

use Moose;
use namespace::autoclean;

use OokOok::Collection::Page;
use OokOok::Collection::PagePart;
use OokOok::Resource::Page;
use OokOok::Resource::PagePart;

BEGIN {
  extends 'OokOok::Base::REST';
}

__PACKAGE__ -> config(
  map => {
  },
  default => 'text/html',
);

sub base :Chained('/') :PathPart('page') :CaptureArgs(0) {
  my($self, $c) = @_;

  if($c -> stash -> {development} || $c -> stash -> {date}) {
    $c -> detach(qw/Controller::Root default/);
  }

  $c -> stash -> {development} = 1; # for use by resources/collections

  $c -> stash -> {collection} = OokOok::Collection::Page -> new(c => $c);
}

sub page_parts :Chained('resource_base') :PathPart('page-part') :Args(0) :ActionClass('REST') { }

sub page_parts_GET {
  my($self, $c) = @_;

  my $data = $c -> stash -> {page} -> _GET(1);
  $self -> status_ok($c,
    entity => {
      _embedded => $data -> {_embedded} -> {page_parts},
      _links => {
        self => $data -> {_links} -> {page_parts},
      },
    }
  );
}

sub page_part :Chained('resource_base') :PathPart('page-part') :Args(1) :ActionClass('REST') {
  my($self, $c, $part_name) = @_;

  my $page = $c -> stash -> {page} -> source -> current_version;
  my $page_part = $page -> page_parts -> search({
    name => $part_name
  }) -> first;

  if(!$page_part) {
    if($c -> request -> method eq 'POST') { # creating
      $page_part = $c -> model("DB::PagePart") -> new({
        page_version_id => $page -> id,
        name => $part_name
      });
    }
    else { # doesn't exist
      $self -> status_not_found($c,
        message => "Resource not found."
      );
      $c -> detach;
    }
  }
  $c -> stash -> {resource} = OokOok::Resource::PagePart->new(c => $c, source => $page_part);
}

sub page_part_PUT { shift -> resource_PUT(@_) }
sub page_part_GET { shift -> resource_GET(@_) }
sub page_part_DELETE { shift -> resource_DELETE(@_) }

sub page_part_POST {
  my($self, $c) = @_;

  my $resource = $c -> stash -> {resource} -> _PUT($c -> req -> data);
  $self -> status_created($c,
    location => $resource -> link,
    entity => $resource -> _GET(1)
  );
}

1;

__END__
