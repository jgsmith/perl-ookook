package OokOok::Controller::Root;
use Moose;
use namespace::autoclean;

use OokOok::Collection::Project;
use OokOok::Collection::Board;
use OokOok::Collection::Theme;
use OokOok::Collection::Library;
use OokOok::Collection::Database;

use YAML::Any ();

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

    my $entity = { };

    if($c -> request -> content_type ne 'text/html') {
      my %embeddings = (
        projects => OokOok::Collection::Project->new(c=>$c),
        boards => OokOok::Collection::Board->new(c=>$c),
        themes => OokOok::Collection::Theme->new(c=>$c),
        libraries => OokOok::Collection::Library->new(c=>$c),
        databases => OokOok::Collection::Database->new(c=>$c),
      );
  
      $entity = {
        _links => {
          self => $c->uri_for('/') -> as_string,
        },
        _auth => { authenticated => 0 },
        _embedded => [
          {
            _links => { self => $embeddings{projects} -> link },
            dataType => 'Project',
            title => 'Projects',
            id => 'projects',
            schema => $embeddings{projects} -> schema,
          },
        ],
      };
  
      if($c -> user) {
        $entity -> {_auth}{authenticated} = 1;
        $c -> stash -> {development} = 1;
        push @{$entity->{_embedded}}, {
          _links => { self => $embeddings{boards} -> link },
          dataType => 'Board',
          title => 'Editorial Boards',
          id => 'boards',
          schema => $embeddings{boards} -> schema,
  #      }, {
  #        _links => $embeddings{libraries} -> GET -> {_links},
  #        dataType => 'Library',
  #        title => 'Libraries',
  #        id => 'libraries',
  #        schema => $embeddings{libraries} -> schema,
  #      }, {
  #        _links => $embeddings{themes} -> GET -> {_links},
  #        dataType => 'Theme',
  #        title => 'Themes',
  #        id => 'themes',
  #        schema => $embeddings{themes} -> schema,
  #      }, {
  #        _links => $embeddings{databases} -> GET -> {_links},
  #        dataType => 'Database',
  #        title => 'Databases',
  #        id => 'databases',
  #        schema => $embeddings{databases} -> schema,
        };
        if($c -> user -> is_admin) {
          push @{$entity->{_embedded}}, {
            _links => { self => $embeddings{themes} -> link },
            dataType => 'Theme',
            title => 'Themes',
            id => 'themes',
            schema => $embeddings{themes} -> schema,
          };
        }
      }
      else {
        $entity -> {_links}{oauth_twitter} = {
          url => $c -> uri_for('/oauth/twitter') -> as_string,
          title => 'Sign in with Twitter',
        };
        $entity -> {_links}{oauth_google} = {
          url => $c -> uri_for('/oauth/google') -> as_string,
          title => 'Sign in with Google',
        };
        $entity -> {_text}{about} = YAML::Any::LoadFile( $c -> path_to( qw/root texts about.yml/ ) );
        $entity -> {_text}{top} = YAML::Any::LoadFile( $c -> path_to( qw/root texts top.yml/ ) );
      }
    }
    $self -> status_ok($c, entity => $entity);
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
