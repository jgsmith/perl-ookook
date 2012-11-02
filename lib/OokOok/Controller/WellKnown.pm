use OokOok::Declare;

# PODNAME: OokOok::Controller::WellKnown

# ABSTRACT: Controller providing /.well-known/ support

controller OokOok::Controller::WellKnown {
  use XML::LibXML;

  use OokOok::Util::Serialization qw( to_link_format );

  use OokOok::Util::XML qw(
    xml
    Property Link
  );

  under '/' {
    action base as ".well-known";
  }

  under base {
    final action host_meta as "host-meta" {
      my $dom = XML::LibXML::Document -> new;
      my $root = $dom -> createElement("XRD");
      $root -> setNamespace( "http://docs.oasis-open.org/ns/xri/xrd-1.0", "", 1 );
      $dom -> setDocumentElement($root);

      # Essentially, timegate and timemap join dev as special timestamps for
      # retrieving resource renderings
      xml($root,
        Link({
          rel => 'timegate',
          template => $ctx -> uri_for('/') . 'timegate/{path}',
        }),
        Link({
          rel => 'timemap',
          template => $ctx -> uri_for('/') . 'timemap/{path}',
        }),
      );

      $ctx -> response -> body( $dom -> toString );
      $ctx -> response -> content_type( 'application/xrd+xml' );
      $ctx -> response -> status( 200 );
    }

    final action core {
      my @links = ();

      push @links, {
        link => $ctx -> uri_for('/') . 'project/',
        title => 'Projects',
        rt => 'index',
      };

      push @links, {
        link => $ctx -> uri_for('/') . 'theme/',
        title => 'Themes',
        rt => 'index',
      };

      $ctx -> response -> body( to_link_format(@links) );
      $ctx -> response -> content_type( 'application/link-format' );
      $ctx -> response -> status( 200 );
    }
  }
}
