use CatalystX::Declare;

controller OokOok::Controller::Admin::OAuth {
  use Catalyst::Authentication::Store::DBIx::Class;

  under '/' {
    final action index (Str $provider) as 'admin/oauth' {
      if($ctx -> request -> method eq 'POST' ||
         $ctx -> session -> {allow_GET_for_oauth}) {
        if($provider eq 'logout') {
          $ctx -> logout;
          $ctx -> res -> redirect($ctx -> uri_for('/'));
        }
        else {
          $ctx -> session -> {allow_GET_for_oauth} = 1;
          if($ctx -> authenticate($provider)) {
            delete $ctx -> session -> {allow_GET_for_oauth};
            my $redirect = delete $ctx -> session -> {redirect};
            $redirect = $ctx -> uri_for('/admin') unless $redirect;
            $ctx -> res -> redirect( $redirect );
          }
        }
      }
      else {
        $ctx -> res -> redirect( $ctx -> uri_for('/') );
      }
    }
  }
}
