package OokOok::Collection::Page;

use OokOok::Collection;
use namespace::autoclean;

use OokOok::Resource::Page;

sub POST {
  my($self, $json) = @_;

  if(!$self -> c -> stash -> {project}) {
    die "Unable to create a page without a project in the stash";
  }

  my $results = $self -> verify($json);
  
  my $page = $self -> c -> stash -> {project} -> source -> create_related('pages', {});

  $page -> current_version -> update( $results );

  $page = OokOok::Resource::Page -> new(
    c => $self -> c,
    source => $page
  );
}

1;
