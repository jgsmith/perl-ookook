package OokOok::Base::TagLibrary;

use Moose;
use MooseX::Types::Moose qw( ArrayRef );
use namespace::autoclean;

use XML::LibXML;

has c => (
  is => 'rw',
  isa => 'Maybe[Object]',
);

has date => (
  is => 'rw',
);

sub process_node {
  my($self, $ctx, $node) = @_;

  # we want to pull out attributes and such based on needs of tag
  my $name = (split(":", $node -> nodeName, 2))[1];
  my $einfo = $self -> meta -> element( $name );
  return if !$einfo; # TODO: perhaps throw an error if not a defined element

  return if !$einfo -> {impl}; # Nothing to do, so don't do anything

  my $context = $ctx -> localize;
  my $xmlns;
  my $attributes = {};
  for my $ns (keys %{$einfo->{attributes}}) {
    $xmlns = $ns;
    if($ns eq '') {
      $xmlns = $self -> meta -> namespace;
    }
    for my $a (keys %{$einfo->{attributes}->{$ns}||{}}) {
      my $value = $node -> getAttributeNS($xmlns, $a);
      if($einfo->{attributes}->{$ns}->{$a} eq 'Str') {
        if(defined $value) {
          $attributes->{$a} = $value;
        }
      }
      elsif($einfo->{attributes}->{$ns}->{$a} eq 'Bool') {
        if(defined($value) && $value =~ m{^\s*(yes|true|on|1)\s*$}i) {
          $attributes->{$a} = 1;
        }
        else {
          $attributes->{$a} = 0;
        }
      }
    }
  }

  my $content;
  if($einfo -> {uses_content} && $node -> hasChildNodes() ) {
    $content = sub { 
      my $collector = [];
      my $child = $node -> firstChild;
      while($child) {
        my $r = $context -> process_node( $child );
        if(ref $r) {
          if(is_ArrayRef($r)) {
            push @$collector, @$r;
          }
          elsif($r -> isa('XML::LibXML::Node')) {
            push @$collector, $r;
          }
        }
        $child = $child -> nextSibling;
      }
      return $collector;
    };
  }

  my $impl = $einfo -> {impl};
  my $r;
  if(ref $impl) {
    $r = $einfo -> {impl} -> ($self, $context, $attributes, $content);
  }
  else {
    $r = $self -> $impl($context, $attributes, $content);
  }

  if(defined($r) && !ref $r) { # $r is a string
    if(!defined($einfo -> {escape_text}) || $einfo->{escape_text}) {
      $r = $node -> ownerDocument -> createTextNode( $r );
    }
    elsif($r ne '') {
      $r =~ s{&}{&amp;}g;
      $r = XML::LibXML -> new(
        expand_entities => 0,
        xinclude => 0,
        load_ext_dtd => 0,
      ) -> parse_balanced_chunk( $r );
    }
    else {
      $r = undef;
    }
  }
  $r;
}

1;
