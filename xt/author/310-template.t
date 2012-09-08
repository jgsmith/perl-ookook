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
  namespaces => {
    r => 'uin:uuid:ypUv1ZbV4RGsjb63Mj8b',
  }
);

$processor -> register_taglib('OokOok::Template::TagLibrary::Core');
my $ns = OokOok::Template::TagLibrary::Core -> meta -> namespace;

my $doc = $processor -> parse( <<EOXML );
<foo>
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
  theme_date => DateTime->now->iso8601,
});

$context -> set_resource(project => $project);

my $result = $doc -> render($context);

diag $result;

done_testing();
