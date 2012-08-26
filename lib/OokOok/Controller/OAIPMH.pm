package OokOok::Controller::OAIPMH;

use Moose;
use namespace::autoclean;
BEGIN {
  extends 'Catalyst::Controller';
}

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

sub info_for_resumptiontoken :Private {
  my($self, $token) = @_;

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

sub resumptiontoken_for_info :Private {
  my($self, $info) = @_;

  my $token = 
    MIME::Base64::encode_base64url(
      Compress::Zlib::memGzip(
        JSON::Any::encode_json( $info )
      )
    );
  return $token;
}

sub oai_for_resource :Private {
  my($self, $c, $resource) = @_;
  my $domain = "ookook.org";

  my $type = $resource -> meta -> {package};
  $type =~ s{^.*::}{};
  $type = decamelize($type);
  
  my $uuid = $resource -> id;

  return "oai:$domain:$type/$uuid";
}

sub resource_for_oai {
  my($self, $c, $oai) = @_;
  my $domain = "ookook.org";

  my @bits = split(/:/, $oai);

  OokOok::Exception::OAIPMH->idDoesNotExist($c) if $bits[0] ne 'oai';
  OokOok::Exception::OAIPMH->idDoesNotExist($c) if $bits[1] ne $domain;

  my($type, $uuid) = split('/', $bits[2], 2);

  $type = camelize($type);
  $type = "OokOok::Collection::$type";
  my $collection = eval { $type -> new(c => $c) };

  OokOok::Exception::OAIPMH->idDoesNotExist($c) unless $collection;

  my $resource = $collection -> resource($uuid);

  OokOok::Exception::OAIPMH->idDoesNotExist($c) unless $resource;

  $resource;
}

sub index :Path :Args(0) {
  my($self, $c) = @_;

  # package data up into an <OAI-PMH/> envelope
  # <responseDate>...</responseDate>
  # <request ...>$c->request->uri</request>
  #          ^-- list of all keys/values in $c -> request -> params
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

  my $uri = $c -> request -> uri;
  xml($root,
    responseDate(DateTime->now->iso8601.'Z'),
    request($c -> request -> params,
      URI::Split::uri_join(
        $uri -> scheme,
        $uri -> authority,
        $uri -> path
      )
    ),
  );
      
  my $verb = $c -> request -> params -> {verb};
  my $method = decamelize($verb);

  my $el = $dom -> createElement( $verb );
  $root -> appendChild($el);

  my $e;
  if($self -> can($method)) {
    eval { $self -> $method($c, $el) };
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

  $c -> response -> body( $dom -> toString );
  $c -> response -> content_type( 'text/xml' );
  $c -> response -> status( 200 );
}

sub identify :Private {
  my($self, $c, $rootEl) = @_;

  my $uri = $c -> request -> uri;

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


sub _get_record {
  my($self, $c, $rootEl, $resource, $metadataPrefix) = @_;

  # now we do proper feeding of metadata into $rootEl
  my $recEl = $rootEl -> createElement( "record" );
  $rootEl -> appendChild( $recEl );

  my $headerEl = $rootEl -> createElement( 'header' );
  my $metadataEl = $rootEl -> createElement( 'metadata' );
  $recEl -> appendChild( $headerEl );
  $recEl -> appendChild( $metadataEl );

  xml( $headerEl,
    identifier(
      $self -> oai_for_resource( $c, $resource )
    )
  );

  $resource -> GET_oai_pmh($headerEl, $metadataEl, $metadataPrefix);
}

sub _get_header {
  my($self, $c, $rootEl, $resource, $metadataPrefix) = @_;

  # now we do proper feeding of metadata into $rootEl
  my $recEl = $rootEl -> createElement( "record" );
  $rootEl -> appendChild( $recEl );

  my $headerEl = $rootEl -> createElement( 'header' );
  $recEl -> appendChild( $headerEl );

  xml( $headerEl,
    identifier(
      $self -> oai_for_resource( $c, $resource )
    )
  );
  $resource -> GET_oai_pmh($headerEl);
}

sub get_record :Private {
  my($self, $c, $rootEl) = @_;

  my $identifier = $c -> request -> params -> {identifier};
  my $resource = $self -> resource_for_oai($c, $identifier);

  my $metadataPrefix = $self -> request -> params -> {metadataPrefix};

  $self -> _get_record($c, $rootEl, $resource, $metadataPrefix);
}

sub list_identifiers :Private {
  my($self, $c, $rootEl) = @_;

  my($set, $from, $until, $metadataPrefix, $offset, $total, $count);

  # TODO: make $count tunable/configurable
  $count = 10; # ten records at a time for now

  my $resumptionToken = $c -> request -> params -> {resumptionToken};

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
    $set = $c -> request -> params -> {set};
    $from = $c -> request -> params -> {from};
    $until = $c -> request -> params -> {until};
    $metadataPrefix = $c -> request -> params -> {metadataPrefix};
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

sub list_metadata_formats :Private {
  my($self, $c, $rootEl) = @_;

  my $identifier = $c -> request -> params -> {identifier};
  my $resource = $self -> resource_for_oai( $identifier );

}

sub list_records :Private {
  my($self, $c, $rootEl) = @_;

  my($set, $from, $until, $metadataPrefix, $offset, $total, $count);

  # TODO: make $count tunable/configurable
  $count = 10; # ten records at a time for now

  my $resumptionToken = $c -> request -> params -> {resumptionToken};

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
    $set = $c -> request -> params -> {set};
    $from = $c -> request -> params -> {from};
    $until = $c -> request -> params -> {until};
    $metadataPrefix = $c -> request -> params -> {metadataPrefix};
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


1;

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

