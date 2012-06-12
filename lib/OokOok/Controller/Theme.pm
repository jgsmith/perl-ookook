package OokOok::Controller::Theme;
use Moose;
use namespace::autoclean;
use JSON;

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
          title => $_ -> title,
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
    for my $col (qw/title layout/) {
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
    $self -> status_created(
      $c,
      location => $c -> uri_for("/theme/$uuid/layout/$tuuid"),
      entity => {
        layout => {
          uuid => $tuuid,
          title => $layout -> title,
          layout => $layout -> layout,
        }
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


=head1 AUTHOR

James Smith,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
