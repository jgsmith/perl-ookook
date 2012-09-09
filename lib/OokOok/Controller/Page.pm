use OokOok::Declare;

# PODNAME: OokOok::Controller::Page

# ABSTRACT: Controller for Page REST interface

rest_controller OokOok::Controller::Page {

  $CLASS -> config(
    map => {
    },
    default => 'text/html',
  );

  under resource_base {
    final action page_parts as "page-part" isa REST;

    action page_part_base  (Str $part_name) as "page-part" {
      my $page = $ctx -> stash -> {page} -> source -> current_version;
      my $page_part = $page -> page_parts -> search({
        name => $part_name
      }) -> first;

      if(!$page_part) {
        if($ctx -> request -> method eq 'POST') { # creating
          $page_part = $ctx -> model("DB::PagePart") -> new({
            page_version_id => $page -> id,
            name => $part_name
          });
        }
        else { # doesn't exist
          $self -> status_not_found($ctx,
            message => "Resource not found."
          );
          $ctx -> detach;
        }
      }
      $ctx -> stash -> {resource} = OokOok::Resource::PagePart->new(c => $ctx, source => $page_part);
    }
  }

  under page_part_base {
    final action page_part as '' isa REST;
  }

  method page_parts_GET ($ctx) {
    my $data = $ctx -> stash -> {page} -> _GET(1);
    $self -> status_ok($ctx,
      entity => {
        _embedded => $data -> {_embedded} -> {page_parts},
        _links => {
          self => $data -> {_links} -> {page_parts},
        },
      }
    );
  }

  method page_part_PUT ($ctx) { $self -> resource_PUT($ctx); }
  method page_part_GET ($ctx) { $self -> resource_GET($ctx); }
  method page_part_DELETE ($ctx) { $self -> resource_DELETE($ctx); }

  method page_part_POST ($ctx) {
    my $resource = $ctx -> stash -> {resource} -> _PUT($ctx -> req -> data);
    $self -> status_created($ctx,
      location => $resource -> link,
      entity => $resource -> _GET(1)
    );
  }
}
