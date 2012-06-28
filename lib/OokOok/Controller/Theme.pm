package OokOok::Controller::Theme;
use Moose;
use namespace::autoclean;
use JSON;

use OokOok::Collection::Theme;

BEGIN { 
  extends 'Catalyst::Controller::REST'; 
  with 'OokOok::Role::Controller::Manager';
  with 'OokOok::Role::Controller::HasEditions';
}

=head1 NAME

OokOok::Controller::Theme - Catalyst Controller

=head1 DESCRIPTION

Provides the REST API for theme management used by the theme management
web pages. These should not be considered a general purpose API.

=head1 METHODS

=cut

__PACKAGE__ -> config(
  map => {
    'text/html' => [ 'View', 'HTML' ],
  },
  default => 'text/html',
  current_model => 'DB::Theme',
  collection_resource_class => 'OokOok::Collection::Theme',
);

#
# manager_base establishes the root slug for the theme management
# functions
#
sub base :Chained('/') :PathPart('theme') :CaptureArgs(0) { }

sub layouts :Chained('thing_base') :PathPart('layout') :Args(0) :ActionClass('REST') { }

sub layouts_GET {
  my($self, $c) = @_;

  my %layouts;
  my $q = $c -> model("DB::ThemeLayout");

  $q = $q -> search(
    {
      "theme_edition.theme_id" => $c -> stash -> {theme} -> id
    },
    {
      join => [qw/theme_edition/]
    }
  );

  my $uuid;

  while(my $p = $q -> next) {
    $uuid = $p -> uuid;
    if($layouts{$uuid}) {
      if($p -> edition -> id > $layouts{$uuid}->edition->id) {
        $layouts{$uuid} = $p;
      }
    }
    else {
      $layouts{$uuid} = $p;
    }
  }

  $self -> status_ok(
    $c,
    entity => {
      theme_layouts => [
        map { +{
          uuid => $_ -> uuid,
          name => $_ -> name,
        } } values %layouts
      ]
    }
  );
}

sub layouts_POST {
  my($self, $c) = @_;

  my $layout;
  eval {
    my %columns;
    my $data = $c -> req -> data;
    for my $col (qw/name/) {
      $columns{$col} = $data -> {$col} if defined $data -> {$col};
    }

    $layout = $c -> stash -> {theme_edition} -> create_related('layouts', \%columns);
  };

  if($@) {
    $self -> status_bad_request(
      $c,
      message => "Unable to create layout: $@",
    );
  }
  else {
    my $tuuid = $layout -> uuid;
    my $uuid = $c -> stash -> {theme} -> uuid;
    my $url = $c -> uri_for("/theme/" . $layout -> edition -> theme -> uuid . "/layout/" . $tuuid);
    $self -> status_created(
      $c,
      location => $url,
      entity => {
        uuid => $tuuid,
        name => $layout -> name,
        layout => $layout -> layout,
        configuration => $layout -> configuration,
        url => $url,
      }
    );
  }
}

sub layouts_OPTIONS {
  my($self, $c) = @_;

  $self -> do_OPTIONS($c,
    Allow => [qw/GET OPTIONS PUT/],
    Accept => [qw{application/json}],
  );
}

sub layout_base :Chained('thing_base') :PathPart('layout') :CaptureArgs(1) {
  my($self, $c, $uuid) = @_;

  my $layout = $c -> stash -> {theme} -> layout_for_date($uuid);

  if($layout) {
    $c -> stash -> {layout} = $layout;
  }
  else {
    $c -> detach(qw/Controller::Root default/);
  }
}

sub layout :Chained('layout_base') :PathPart('') :Args(0) :ActionClass('REST') { }

sub layout_GET {
  my($self, $c) = @_;

  my $layout = $c -> stash -> {layout};

  $self -> status_ok($c,
    entity => {
      uuid => $layout -> uuid,
      url => "".$c -> uri_for("/theme/" . $layout -> edition -> theme -> uuid . "/layout/" . $layout -> uuid),
      name => $layout -> name,
      layout => $layout -> layout,
      configuration => $layout -> configuration,
    }
  );
}


=head1 AUTHOR

James Smith,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
