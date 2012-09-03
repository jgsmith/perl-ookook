package OokOok::Test::REST;

use Catalyst::Test 'OokOok';

use Exporter;
use HTTP::Request::Common;
use JSON;
use Test::More;

our @ISA = qw(Exporter);
our @EXPORT = qw(GET_ok GET_not_ok PUT_ok POST_ok DELETE_ok request);

sub GET_ok {
  my($url, $desc) = @_;

  my($res, $json);
  my $headers = HTTP::Headers -> new;

  $headers -> header('Accept' => 'application/json');
  $headers -> header('Content-Type' => 'application/json');

  ok( $res = request(
    HTTP::Request->new( GET => $url, $headers )
  ), "GET: $desc");

  #diag( "Request Content: " . $res -> content );

  eval { $json = decode_json($res -> content) };
  ok !$@, "Decode: $desc";
  return $json;
}

sub GET_not_ok {
  my($url, $desc) = @_;

  my($res, $json);
  my $headers = HTTP::Headers -> new;

  $headers -> header('Accept' => 'application/json');
  $headers -> header('Content-Type' => 'application/json');

  $res = request(
    HTTP::Request->new( GET => $url, $headers )
  );

  ok( $res->code >= 400, "GET failed successfully: $desc" );
}

sub PUT_ok {
  my($url, $content, $desc) = @_;

  my($res, $json);
  if(ref $content) {
    $content = encode_json $content;
  }

  my $headers = HTTP::Headers -> new;

  $headers -> header('Accept' => 'application/json');
  $headers -> header('Content-Type' => 'application/json');

  ok( $res = request(
    HTTP::Request->new( PUT => $url, $headers, $content )
  ), "PUT: $desc");

  diag $res -> content unless $res -> code < 300;

  eval { $json = decode_json($res -> content) };
  ok !$@, "Decode: $desc";
  return $json;
}

sub POST_ok {
  my($url, $content, $desc) = @_;

  my($res, $json);
  if(ref $content) {
    $content = encode_json $content;
  }

  my $headers = HTTP::Headers -> new;

  $headers -> header('Accept' => 'application/json');
  $headers -> header('Content-Type' => 'application/json');

  ok( $res = request(
    HTTP::Request->new( POST => $url, $headers, $content )
  ), "POST: $desc");

  diag( "POST url: $url" );
  diag( "Response content: " . $res -> content );
  diag $res -> content unless $res -> code < 300;

  eval { $json = decode_json($res -> content) };
  ok !$@, "Decode: $desc";
  return $json;
}

sub DELETE_ok {
  my($url, $desc) = @_;

  my $headers = HTTP::Headers -> new;

  $headers -> header('Accept' => 'application/json');
  $headers -> header('Content-Type' => 'application/json');

  # We add an empty JSON body to satisfy the deserializer in Catalyst
  my($res);
  ok( $res = request(
    HTTP::Request->new( DELETE => $url, $headers, "{}" )
  ), "DELETE: $desc");
}

1;
