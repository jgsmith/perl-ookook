#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

BEGIN {
  $ENV{'OOKOOK_CONFIG_LOCAL_SUFFIX'} = "testing";

  use_ok( 'OokOok::Template::Processor' );
  use_ok( 'OokOok::Template::Document' );
  use_ok( 'OokOok::Template::TagLibrary::Core' );
}

use OokOok;
use DateTime;

my $c = OokOok->new;

$c -> stash -> {development} = 1;
$c -> stash -> {date} = DateTime->now;

my $processor = OokOok::Template::Processor -> new(
  c => $c,
);

$processor -> register_taglib('OokOok::Template::TagLibrary::Core');

my $doc = $processor -> parse( <<EOXML );
<foo xmlns:r="http://www.ookook.org/ns/core/1.0">
  <bar/>
  <r:snippet r:name="bar" />
  <!-- comment -->
</foo>
EOXML

my $context = OokOok::Template::Context -> new;

my $theme_collection = OokOok::Collection::Theme -> new(c => $c);
my $theme = $theme_collection -> _POST({
  name => 'FooTheme',
  description => "Test Theme",
});

my $project_collection = OokOok::Collection::Project->new(c => $c);
my $project = $project_collection -> _POST({
  name => 'Foo',
  description => 'Test project',
  theme => $theme->id,
  theme_date => "".DateTime->now
});

$context -> set_resource(project => $project);

my $result = $doc -> render();

diag $result;

done_testing();
