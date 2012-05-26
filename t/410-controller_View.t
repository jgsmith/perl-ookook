use strict;
use warnings;
use Test::More;
use HTTP::Request::Common;
use JSON;

BEGIN {
  $ENV{'OOKOOK_CONFIG_LOCAL_SUFFIX'} = "testing";
}


use Catalyst::Test 'OokOok';
use OokOok::Controller::View;

#
# Set up our protocol helpers
#

sub GET_ok {
  my($url, $desc) = @_;

  my($res, $json);
  my $headers = HTTP::Headers -> new;

  $headers -> header('Accept' => 'application/json');
  $headers -> header('Content-Type' => 'application/json');

  ok( $res = request(
    HTTP::Request->new( GET => $url, $headers )
  ), "GET: $desc");

  #diag( $res -> content );

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

#
# Create project and populate with sitemap
#

my $json;
my $uuid;

$json = POST_ok("/project", {
  name => "Test Project",
  description => "Test project description",
}, "create project");

my $uuid = $json -> {project} -> {uuid};

#
# Now we need to add a few pages to the project
#

$json = GET_ok("/project/$uuid/page", "Get list of pages");

ok $json->{pages}, "JSON has pages property";
is scalar(@{$json->{pages}}), 0, "No pages in project yet";

$json = POST_ok("/project/$uuid/page", {
  title => "Page Title",
  description => "Description of page",
}, "create page");

ok $json->{page}, "JSON has page property";
my $page_uuid = $json->{page}->{uuid};
ok $page_uuid, "JSON has page uuid";
is $json->{page}->{title}, "Page Title", "Right value for title";
is $json->{page}->{description}, "Description of page", "Right value for description";

$json = GET_ok("/project/$uuid/page", "Get list of pages");

ok $json->{pages}, "JSON has pages property";
is scalar(@{$json->{pages}}), 1, "One page in project";

$json = GET_ok("/project/$uuid/page/$page_uuid", "Get page info");

ok $json->{page}, "JSON has page property";
is $json->{page}->{uuid}, $page_uuid, "Right uuid";
is $json->{page}->{title}, "Page Title", "Right value for title";
is $json->{page}->{description}, "Description of page", "Right value for description";


#
# Then create a sitemap with the pages
#

PUT_ok("/project/$uuid/sitemap", {
  '' => {
    children => {
    }
  }
}, "Create sitemap");

ok( !request('/v')->is_success, 'Request should not succeed' );
done_testing();
