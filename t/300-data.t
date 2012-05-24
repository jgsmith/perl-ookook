#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 11;

BEGIN { use_ok( 'OokOok::Data::Store' ); }

my $store = OokOok::Data::Store->new;

ok(defined $store, "Store object created");

isa_ok($store, "OokOok::Data::Store", "It's a Data::Store!");

is($store->size, 0, "Nothing in it yet");
is_deeply([$store->items], [], "Nothing in it yet");

eval{
$store->loadItems({
  id => "foo",
  type => "Example",
  bar => ["baz", "bat"]
});
};
if($@) { diag($@); }
ok(!$@, "Loaded item without error");

is($store->size, 1, "One item loaded");
is_deeply([ $store->items ], ["foo"], "One item with id 'foo'");

my $item = $store -> getItem("foo");

ok(defined($item), "We get an item back for 'foo'");
isa_ok($item->{"bar"}, "Set::Scalar", "The bar property is a set");
is($item->{"bar"}->size, 2, "The bar property has two values");

