use strict;
use warnings;
use Test::More;
use HTTP::Request::Common;
use JSON;

BEGIN {
  $ENV{'OOKOOK_CONFIG_LOCAL_SUFFIX'} = "testing";
}

use Catalyst::Test 'OokOok';

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
# Get an empty listing of projects
#

my $json;

$json = GET_ok("/project", "JSON listing of projects");

is_deeply $json, { projects => [] }, "Empty list of projects";

#
# Create a project
#

$json = POST_ok("/project", {
    name => "Test Project",
    description => "Test project description",
  }, "create project");

is $json->{project}->{name}, "Test Project", "Name returned";
is $json->{project}->{description}, "Test project description", "Description returned";
ok $json->{project}->{uuid}, "Project has a uuid";
ok $json->{project}->{id}, "Project has an id";

my $uuid = $json->{project}->{uuid};

#
# Get the newly created project
#
$json = GET_ok("/project/$uuid", "Get new project");

is $json->{project}->{name}, "Test Project", "Right name returned";
is $json->{project}->{description}, "Test project description", "Right description returned";
is $json->{project}->{uuid}, $uuid, "Right uuid returned";

#
# See if list of projects has one member
#

$json = GET_ok("/project", "JSON listing of projects");

ok $json->{projects}, "Projects key exists in returned JSON";
is scalar(@{$json->{projects}}), 1, "One project";
is $json->{projects}->[0]->{uuid}, $uuid, "Right project";

#
# Now see if we can delete the project
#

DELETE_ok("/project/$uuid", "delete project");

#
# Now we should have no projects again
#

$json = GET_ok("/project", "JSON listing of projects");

ok $json->{projects}, "Projects key exists in returned JSON";
is scalar(@{$json->{projects}}), 0, "No projects";

done_testing();
