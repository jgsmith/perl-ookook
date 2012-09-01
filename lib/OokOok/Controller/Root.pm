use CatalystX::Declare;

controller OokOok::Controller::Root 
   extends Catalyst::Controller::REST
{

  use OokOok::Collection::Project;
  use OokOok::Collection::Board;
  use OokOok::Collection::Theme;
  use OokOok::Collection::Library;
  use OokOok::Collection::Database;

  use YAML::Any ();

  $CLASS -> config(
    namespace => '',
    map => {
      'text/html' => [ 'View', 'Mason' ],
    },
    default => 'text/html',
  );

  under '/' {

    final action index as '' isa REST;

    final action index_GET is private {
      my $entity = { };

      if($ctx -> request -> content_type ne 'text/html') {
        my %embeddings = (
          projects => OokOok::Collection::Project->new(c=>$ctx),
          boards => OokOok::Collection::Board->new(c=>$ctx),
          themes => OokOok::Collection::Theme->new(c=>$ctx),
          libraries => OokOok::Collection::Library->new(c=>$ctx),
          databases => OokOok::Collection::Database->new(c=>$ctx),
        );

        $entity = {
          _links => {
            self => $ctx->uri_for('/') -> as_string,
          },
          _auth => { authenticated => 0 },
          _embedded => [ ]
        };

        if($ctx -> user) {
          $entity -> {_auth}{authenticated} = 1;
          $ctx -> stash -> {development} = 1;
        }
  
        push @{$entity->{_embedded}}, {
          _links => { self => $embeddings{projects} -> link },
          dataType => 'Project',
          title => 'Projects',
          id => 'projects',
          schema => $embeddings{projects} -> schema,
        };
  
        if($ctx -> user) {
          push @{$entity->{_embedded}}, {
            _links => { self => $embeddings{boards} -> link },
            dataType => 'Board',
            title => 'Editorial Boards',
            id => 'boards',
            schema => $embeddings{boards} -> schema,
          };
          if($ctx -> user -> is_admin) {
            push @{$entity->{_embedded}}, {
              _links => { self => $embeddings{themes} -> link },
              dataType => 'Theme',
              title => 'Themes',
              id => 'themes',
              schema => $embeddings{themes} -> schema,
            };
          }
        }
      }
      $self -> status_ok($ctx, entity => $entity);
    }

    final action index_OPTIONS is private {
      $ctx -> response -> status(200);
      $ctx -> response -> headers -> header(
        Allow => [qw/GET OPTIONS/],
        Accept => [qw{application/json text/html}],
      );
      $ctx -> response -> body('');
      $ctx -> response -> content_length(0);
      $ctx -> response -> content_type("text/plain");
      $ctx -> detach;
    }

    final action default (@args) {
      $ctx->stash->{template} = 'notfound.tt2';
      $ctx->forward( $ctx -> view( 'HTML' ) );
      $ctx->response->status(404);
    }
  }

  final action end (@) isa RenderView {
    if( scalar @{ $ctx->error } ) {
      $ctx->stash->{errors}   = $ctx->error;
      for my $error ( @{ $ctx->error } ) {
        $ctx->log->error($error);
      }
      $ctx->stash->{template} = 'errors.tt2';
      $ctx->forward( $ctx -> view( 'HTML' ) );
      $ctx->clear_errors;
    }
 
    return 1 if $ctx->response->status =~ /^3\d\d$/;
    return 1 if $ctx->response->body;
 
    unless ( $ctx->response->content_type ) {
        $ctx->response->content_type('text/html; charset=utf-8');
    }

    $ctx->forward( $ctx -> view('Mason') );
  }
}
