use OokOok::Declare;

# PODNAME: OokOok::Controller::Root

# ABSTRACT: Controller for front page of OokOok-based site

controller OokOok::Controller::Root {

  use OokOok::Collection::Project;
  use OokOok::Collection::Board;
  use OokOok::Collection::Theme;
  use OokOok::Collection::Library;
  use OokOok::Collection::Database;

  __PACKAGE__ -> config(
    namespace => '',
    map => {
      'text/html' => [ 'View', 'Mason' ],
    },
    default => 'text/html',
  );

  under '/' {

    final action index as '' {
      my $entity = { };

      my $page = $ctx -> request -> params->{page} || 1;
      my @posts;
      my $editions = $ctx -> model('DB::Edition') -> search({
          'me.published_for' => { '!=' => undef },
        }, {
          page => $page,
          order_by => { -desc => 'me.published_for' },
        }
      );

      my $last_project_uuid = "";
      for my $edition ($editions -> all) {
        next if $edition -> project -> uuid eq $last_project_uuid;
        $last_project_uuid = $edition -> project -> uuid;
        push @posts, {
          class => 'span' . ($page > 2 ? 2 : (8 - 2*$page)),
          title => $edition -> name,
          link => $ctx->uri_for('/') . $edition -> closed_on . '/v/' . $edition -> project -> uuid . '/',
          content => '<p>' . $edition -> description . '</p>',
        };
      }

      $ctx -> stash -> {posts} = [ @posts ];
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
