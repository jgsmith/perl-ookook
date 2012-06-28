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

$uuid = $json -> {uuid};

#
# Now we need to add a few pages to the project
#

$json = GET_ok("/project/$uuid/page", "Get list of pages");

ok $json->{_embedded}->{pages}, "JSON has pages property";
is scalar(@{$json->{_embedded}->{pages}}), 1, "One page in project";

my %pages;

for my $nom (qw/Foo Bar Baz/) {

  $json = POST_ok("/project/$uuid/page", {
    title => "$nom Title",
    description => "Description of " . lc($nom) . " page",
  }, "create $nom page");

  my $page_uuid = $json->{uuid};
  ok $page_uuid, "JSON has page uuid";
  is $json->{title}, "$nom Title", "Right value for title";
  is $json->{description}, "Description of ".lc($nom)." page", "Right value for description";

  $pages{$nom} = $page_uuid;

}

$json = GET_ok("/project/$uuid/page", "Get list of pages");

ok $json->{_embedded}->{pages}, "JSON has pages property";
is scalar(@{$json->{_embedded}->{pages}}), 4, "Four pages in project";

#
# Then create a sitemap with the pages
#

PUT_ok("/project/$uuid", {
  sitemap => {
    '' => {
      children => {
        'about' => {
          'visual' => $pages{"Bar"}
        },
        'projects' => {
          'children' => {
            'ookook' => {
              'visual' => $pages{"Baz"}
            },
          },
        },
      },
      'visual' => $pages{"Foo"}
    },
  },
}, "Create sitemap");

ok( !request('/v')->is_success, 'Request should not succeed' );

ok( request("/dev/v/$uuid/") -> is_success, 'Request should succeed' );

ok( !request("/dev/v/$uuid/boo") -> is_success, "/boo isn't in project" );
ok( request("/dev/v/$uuid/about") -> is_success, "/about is in project" );
ok( !request("/dev/v/$uuid/projects") -> is_success, "/projects isn't in project" );
ok( request("/dev/v/$uuid/projects/ookook") -> is_success, "/projects/ookook is in project" );

my $before_date = DateTime->now;
$before_date = $before_date->ymd('').$before_date->hms('');

ok( !request("/$before_date/v/$uuid/")->is_success, "No frozen edition yet");

ok( !request("/v/$uuid/") -> is_success, "No available edition yet");

sleep(2);

POST_ok("/project/$uuid/edition", {}, "Create a frozen edition");

sleep(2);

my $after_date = DateTime->now;
$after_date = $after_date->ymd('').$after_date->hms('');

ok( !request("/$before_date/v/$uuid/")->is_success, "Date preceeds freeze");
ok( request("/$after_date/v/$uuid/")->is_success, "Date is after freeze");

#
# Now see if dev site is still available
#

ok( request("/dev/v/$uuid/about") -> is_success, "About page is still there");

done_testing();
