package OokOok::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__ -> config(
  namespace => '',
  map => {
    'text/html' => [ 'View', 'HTML' ],
  },
  default => 'text/html',
);


=head1 NAME

OokOok::Controller::Root - Root Controller for OokOok

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) :ActionClass('REST') { }

sub index_GET {
    my ( $self, $c ) = @_;

    if($c -> user) {
      my %embeddings = (
        projects => OokOok::Collection::Project->new(c=>$c)->GET,
        libraries => OokOok::Collection::Library->new(c=>$c)->GET,
        themes => OokOok::Collection::Theme->new(c=>$c)->GET,
      );
      
      $self -> status_ok($c,
        entity => {
          _links => { 
            self => $c->uri_for('/') -> as_string,
            projects => $embeddings{projects}{_links}{self},
            libraries => $embeddings{libraries}{_links}{self},
            themes => $embeddings{themes}{_links}{self},
          },
          _embedded => {
            projects => $embeddings{projects}{_embedded}{projects},
            libraries => $embeddings{libraries}{_embedded}{libraries},
            themes => $embeddings{themes}{_embedded}{themes},
          }
        }
      );
      $c -> stash(template => 'dashboard.tt2');
    }
    else {
      $self -> status_ok($c,
        entity => {
          _links => { self => $c -> uri_for('/') -> as_string },
        }
      );
      $c -> stash(template => 'index.tt2');
    }
}

sub index_OPTIONS {
  my($self, $c) = @_;

  $c -> response -> status(200);
  $c -> response -> headers -> header(
    Allow => [qw/GET OPTIONS/],
    Accept => [qw{application/json text/html}],
  );
  $c -> response -> body('');
  $c -> response -> content_length(0);
  $c -> response -> content_type("text/plain");
  $c -> detach;
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;

    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

#sub end : ActionClass('RenderView') {}

=head1 AUTHOR

James Smith,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
