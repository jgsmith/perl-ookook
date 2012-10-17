use OokOok::Declare;

# PODNAME: OokOok::Controller::OAIPMH

# ABSTRACT: Controller providing OAI-PMH support

controller OokOok::Controller::OAIPMH {
  use String::CamelCase qw(camelize decamelize);
  use XML::LibXML;
  use DateTime;
  use URI::Split ();
  use OokOok::Exception;
  use Compress::Zlib ();
  use JSON::Any ();

  use OokOok::Util::XML qw(
    xml 
    repositoryName baseURL protocolVersion deletedRecord granularity
    earliestDatestamp
    adminEmail
    resumptionToken
    request responseDate
    identifier
  );

  __PACKAGE__ -> config(
    namespace => 'oai-pmh',
    domain => "ookook.org",
  );

  method info_for_resumptiontoken ($token) {
    my $info = eval {
      JSON::Any::decode_json(
        Compress::Zlib::memGunzip(
          MIME::Base64::decode_base64url( $token )
        )
      )
    };

    OokOok::Exception::OAIPMH -> badResumptionToken if $@ or not defined($info);

    return $info;
  }

  method resumptiontoken_for_info ($info) {
    my $token = 
      MIME::Base64::encode_base64url(
        Compress::Zlib::memGzip(
          JSON::Any::encode_json( $info )
        )
      );
    return $token;
  }

  method oai_for_resource ($ctx, $resource) {
    my $domain = "ookook.org";

    my $type = $resource -> meta -> {package};
    $type =~ s{^.*::}{};
    $type = decamelize($type);
  
    my $uuid = $resource -> id;

    return "oai:$domain:$type/$uuid";
  }

  method resource_for_oai ($ctx, $oai) {
    my $domain = "ookook.org";

    my @bits = split(/:/, $oai);

    OokOok::Exception::OAIPMH->idDoesNotExist($ctx) if $bits[0] ne 'oai';
    OokOok::Exception::OAIPMH->idDoesNotExist($ctx) if $bits[1] ne $domain;

    my($type, $uuid) = split('/', $bits[2], 2);

    $type = camelize($type);
    $type = "OokOok::Collection::$type";
    my $collection = eval { $type -> new(c => $ctx) };

    OokOok::Exception::OAIPMH->idDoesNotExist($ctx) unless $collection;

    my $resource = $collection -> resource($uuid);

    OokOok::Exception::OAIPMH->idDoesNotExist($ctx) unless $resource;

    $resource;
  }

  final action index as '' {
    # package data up into an <OAI-PMH/> envelope
    # <responseDate>...</responseDate>
    # <request ...>$ctx->request->uri</request>
    #          ^-- list of all keys/values in $ctx -> request -> params
    #
    # <$verb>...</$verb>

    # we have to build a DOM since we're using so many namespaces :-/
    my $dom = XML::LibXML::Document -> new;

    my $root = $dom -> createElement("OAI-PMH");
    $root -> setNamespace( "http://www.openarchives.org/OAI/2.0/", "", 1 );

    $dom -> setDocumentElement($root);

    $root -> setNamespace( "http://www.openarchives.org/OAI/2.0/", "xsi", 0 );
    $root -> setAttributeNS(
      "http://www.openarchives.org/OAI/2.0/", "schemaLocation",
      "http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd"
    );

    my $uri = $ctx -> request -> uri;
    xml($root,
      responseDate(DateTime->now->iso8601.'Z'),
      request($ctx -> request -> params,
        URI::Split::uri_join(
          $uri -> scheme,
          $uri -> authority,
          $uri -> path
        )
      ),
    );
      
    my $verb = $ctx -> request -> params -> {verb};
    my $method = decamelize($verb);

    my $el = $dom -> createElement( $verb );
    $root -> appendChild($el);

    my $e;
    if($self -> can($method)) {
      eval { $self -> $method($ctx, $el) };
      $e = $@;
    }
    else {
      # not the most efficient :-/
      $e = eval { OokOok::Exception::OAIPMH->badVerb };
    }
    if($e) {
      # handle errors
      $el -> unbindNode;
      $el = $dom -> createElement( "error" );
      if(blessed($e) && $e -> isa("OokOok::Exception::OAIPMH")) {
        $el -> setAttribute("code", $e -> code);
        $el -> appendText( $el -> message );
      }
      else {
        die $e;
      }
    }

    $ctx -> response -> body( $dom -> toString );
    $ctx -> response -> content_type( 'text/xml' );
    $ctx -> response -> status( 200 );
  }

  method identify ($ctx, $rootEl) {
    my $uri = $ctx -> request -> uri;

    xml( $rootEl,
      repositoryName("OokOok"),
      baseURL(
        URI::Split::uri_join(
          $uri -> scheme,
          $uri -> authority,
          $uri -> path
        )
      ),
      protocolVersion("2.0"),
      deletedRecord("persistent"),
      granularity("YYYY-MM-DDThh:mm:ssZ"),
      earliestDatestamp(
        DateTime->now->iso8601.'Z'
      ),
      (map { adminEmail($_) } (qw/foo@example.com/)),
    );
  }

  method _get_record ($ctx, $rootEl, $resource, $metadataPrefix) {
    # now we do proper feeding of metadata into $rootEl
    my $recEl = $rootEl -> createElement( "record" );
    $rootEl -> appendChild( $recEl );

    my $headerEl = $rootEl -> createElement( 'header' );
    my $metadataEl = $rootEl -> createElement( 'metadata' );
    $recEl -> appendChild( $headerEl );
    $recEl -> appendChild( $metadataEl );

    xml( $headerEl,
      identifier(
        $self -> oai_for_resource( $ctx, $resource )
      )
    );

    $resource -> GET_oai_pmh($headerEl, $metadataEl, $metadataPrefix);
  }

  method _get_header ($ctx, $rootEl, $resource, $metadataPrefix) {
    # now we do proper feeding of metadata into $rootEl
    my $recEl = $rootEl -> createElement( "record" );
    $rootEl -> appendChild( $recEl );

    my $headerEl = $rootEl -> createElement( 'header' );
    $recEl -> appendChild( $headerEl );

    xml( $headerEl,
      identifier(
        $self -> oai_for_resource( $ctx, $resource )
      )
    );
    $resource -> GET_oai_pmh($headerEl);
  }

  method get_record ($ctx, $rootEl) {
    my $identifier = $ctx -> request -> params -> {identifier};
    my $resource = $self -> resource_for_oai($ctx, $identifier);

    my $metadataPrefix = $self -> request -> params -> {metadataPrefix};

    $self -> _get_record($ctx, $rootEl, $resource, $metadataPrefix);
  }

  method list_identifiers ($ctx, $rootEl) {
    my($set, $from, $until, $metadataPrefix, $offset, $total, $count);

    # TODO: make $count tunable/configurable
    $count = 10; # ten records at a time for now

    my $resumptionToken = $ctx -> request -> params -> {resumptionToken};

    if($resumptionToken) {
      # set up context based on token
      my $info = $self -> info_for_resumptiontoken( $resumptionToken );
      $offset = $info -> {offset};
      $set = $info -> {set};
      $from = $info -> {from};
      $until = $info -> {until};
      $metadataPrefix = $info -> {metadataPrefix};
    }
    else {
      # set up context based on other params
      $offset = 0;
      $set = $ctx -> request -> params -> {set};
      $from = $ctx -> request -> params -> {from};
      $until = $ctx -> request -> params -> {until};
      $metadataPrefix = $ctx -> request -> params -> {metadataPrefix};
    }

    if($resumptionToken || $count < $total) {
      # either add another one or a blank if no more records
      xml($rootEl,
        resumptionToken(
          { completeListSize => $total,
            cursor => $offset,
          },
          ($offset + $count < $total ?
            $self -> resumptiontoken_for_info({
              offset => $offset + $count,
              set => $set,
              from => $from,
              until => $until,
              metadataPrefix => $metadataPrefix,
            })
            : ''
          ),
        )
      );
    }
  }

  method list_metadata_formats ($ctx, $rootEl) {
    my $identifier = $ctx -> request -> params -> {identifier};
    my $resource = $self -> resource_for_oai( $identifier );
  }

  method list_records ($ctx, $rootEl) {
    my($set, $from, $until, $metadataPrefix, $offset, $total, $count);

    # TODO: make $count tunable/configurable
    $count = 10; # ten records at a time for now

    my $resumptionToken = $ctx -> request -> params -> {resumptionToken};

    if($resumptionToken) {
      # set up context based on token
      my $info = $self -> info_for_resumptiontoken( $resumptionToken );
      $offset = $info -> {offset};
      $set = $info -> {set};
      $from = $info -> {from};
      $until = $info -> {until};
      $metadataPrefix = $info -> {metadataPrefix};
    }
    else {
      # set up context based on other params
      $offset = 0;
      $set = $ctx -> request -> params -> {set};
      $from = $ctx -> request -> params -> {from};
      $until = $ctx -> request -> params -> {until};
      $metadataPrefix = $ctx -> request -> params -> {metadataPrefix};
    }
  
    if($resumptionToken || $count < $total) {
      # either add another one or a blank if no more records
      xml($rootEl,
        resumptionToken(
          { completeListSize => $total,
            cursor => $offset,
          },
          ($offset + $count < $total ?
            $self -> resumptiontoken_for_info({
              offset => $offset + $count,
              set => $set,
              from => $from,
              until => $until,
              metadataPrefix => $metadataPrefix,
            })
            : ''
          ),
        )
      );
    }
  }
}

__END__

=head1 NAME

OokOok::Controller::OAIPMH - provides a OAI-PMH gateway

=head1 DESCRIPTION

=head1 OAI-PMH "Things"

A C<oai-identifier> is constructed from the configured domain and the
20 character uuid of the object.

oai:$domain:$type:$uuid20

=head1 SEE ALSO

L<http://www.openarchives.org/OAI/2.0/guidelines.htm>

