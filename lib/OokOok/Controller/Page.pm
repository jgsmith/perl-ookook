package OokOok::Controller::Page;
use Moose;
use namespace::autoclean;

BEGIN {
  extends 'Catalyst::Controller::REST';
  with 'OokOok::Role::Controller::Manager';
}

__PACKAGE__ -> config(
  map => {
    'text/html' => [ 'View', 'HTML' ],
  },
  default => 'text/html',
  current_model => 'DB::Page',
);

sub base :Chained('/') :PathPart('page') :CaptureArgs(0) { }

sub constrain_thing_search {
  my($self, $c, $q) = @_;

  $q -> search(undef, {
    order_by => { -desc => 'id' }
  });
}

# Requires the edition to be in the stash.
sub page_from_json {
  my($self, $c, $json) = @_;

  my $page;
  #eval {
    my %columns;
    for my $col (qw/title description/) {
      $columns{$col} = $json -> {$col} if defined $json -> {$col};
    }

    $page = $c -> stash -> {edition} -> create_related('pages', \%columns);
  #};
  #if($@) {
  #  print STDERR "Uh oh: $@";
  #}
  return $page;
}

sub page_to_json {
  my($self, $c, $page, $deep) = @_;

  my $json = {
    uuid => $page -> uuid,
    title => $page -> title,
    description => $page -> description,
    url => "".$c -> uri_for("/page/" . $page->uuid),
  };

  if($deep) {
    $json->{parts} = [ map { $self -> page_part_to_json($c, $_) } $page -> page_parts -> all ];
  }
  else {
    $json->{parts} = [ map { +{
      name => $_ -> name,
      url => $json->{url} . "/" . $_ -> name,
    } } $page -> page_parts -> all ];
  }
  return $json;
}

sub update_page {
  my($self, $c, $page, $json) = @_;

}

sub page_part_to_json {
  my($self, $c, $part, $deep) = @_;

  my $json = {
    name => $part -> name,
    url => "".$c->uri_for("/page/" . $part->page->uuid . "/" . $part->name),
    content => $part -> content,
  };

  return $json;
}

1;
__END__
