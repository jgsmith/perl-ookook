package OokOok::Collection::Edition;

use OokOok::Collection;
use namespace::autoclean;

has project => (
  is => 'rw',
  isa => 'OokOok::Resource::Project',
  lazy => 1,
  default => sub { $_[0] -> c -> stash -> {project} },
);

sub can_POST {
  my($self) = @_;

  # we need to make sure the current logged in person is owner of the project
  1;
}

sub may_POST {
  my($self) = @_;

  if($self -> project -> source -> current_edition -> created_on <
       DateTime->now) {
    return 1;
  }
  return 0;
}

sub POST {
  my($self, $json) = @_;

  # we ignore data in a POST to create a new edition
  my $project = $self -> project -> source;

  my $edition = $project -> current_edition;

  $project -> current_edition -> close;

  $edition = $edition -> get_from_storage;

  print STDERR "Closing date: ", $edition -> closed_on, "\n";

  my @changes;

  my $new_edition = OokOok::Resource::Edition -> new(
    c => $self -> c, 
    date => $self -> date, 
    source => $project -> current_edition,
  );

  # now we need to modify stuff in elasticsearch
  # all we need to do is add the commit date for the document
  # ${uuid}-${date}

  # we need to make search support a job queue operation
  # so we don't make the user spin waiting on it
  my $date = $edition -> closed_on -> iso8601;
  my $project_uuid = $self -> project -> id;

  # pages are indexed for page content
  for my $pv ($edition -> page_versions) {
    my $info = OokOok::Resource::Page->new(
      c => $self -> c,
      is_development => $self -> is_development,
      date => $date,
      source => $pv -> page,
      source_version => $pv,
    ) -> for_search;

    $info -> {'__project'} = $project_uuid;

    #my $res = $self -> c -> model('ES') -> index(
    push @changes, {
      type => 'page',
      id => $pv -> page -> uuid . "-" . $date,
      data => $info,
      create => 1,
      timestamp => $date,
    };
  }

  # snippets are indexed to identify projects in general
  for my $sv ($edition -> snippet_versions) {
    my $info = OokOok::Resource::Snippet -> new(
      c => $self -> c,
      is_development => $self -> is_development,
      date => $date,
      source => $sv -> snippet,
      source_version => $sv,
    ) -> for_search;
 
    $info -> {'__project'} = $project_uuid;

    #my $res = $self -> c -> model('ES') -> index(
    push @changes, {
      type => 'snippet',
      id => $sv -> snippet -> uuid . "-" . $date,
      data => $info,
      create => 1,
      timestamp => $date,
    };
  }

  if(@changes) {
    my $res = $self -> c -> model('ES') -> bulk_index(
      docs => [ @changes ],
      index => 'projects',
      consistency => 'quorum',
      replication => 'async',
      on_conflict => 'IGNORE',
      on_error => 'IGNORE',
    );
  }

  return $new_edition;
}

sub GET {
  my($self, $deep) = @_;

  return {
    _links => {
      self => $self -> link
    },
    _embedded => [
      map {
        OokOok::Resource::Edition->new(c => $self -> c, source => $_) -> GET
     } grep { 
        defined
     } $self -> project -> source -> editions
    ]
  };
}

1;
