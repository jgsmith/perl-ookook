package OokOok::Controller::Page;
use Moose;
use namespace::autoclean;

BEGIN {
  extends 'Catalyst::Controller::REST';
  with 'OokOok::Role::Controller::Manager';
}

__PACKAGE__ -> config(
  map => {
  },
  default => 'text/html',
  current_model => 'DB::Page',
  collection_resource_class => 'OokOok::Collection::Page',
);

sub base :Chained('/') :PathPart('page') :CaptureArgs(0) { }

sub constrain_thing_search {
  my($self, $c, $q) = @_;

  $q -> search(undef, {
    order_by => { -desc => 'id' }
  });
}

1;
__END__
