package OokOok::Template::Context;

use Moose;
use MooseX::Types::Moose qw/CodeRef/;

use XML::LibXML;
use namespace::autoclean;

has parent => (
  isa => 'Maybe[OokOok::Template::Context]',
  is => 'ro',
  predicate => 'has_parent',
);

has document => (
  isa => 'Maybe[OokOok::Template::Document]',
  is => 'ro',
  predicate => 'has_document',
);

has vars => (
  isa => 'HashRef',
  is => 'ro',
  default => sub { +{ } },
  lazy => 1,
);

has resources => (
  isa => 'HashRef',
  is => 'ro',
  default => sub { +{ } },
  lazy => 1,
);

sub localize {
  my($self) = @_;

  OokOok::Template::Context -> new( 
    parent => $self,
    document => $self -> document,
  );
}

sub delocalize {
  my($self) = @_;

  if($self -> has_parent) { return $self -> parent; }
  else                    { return $self;           }
}

sub get_resource {
  my($self, $key) = @_;

  if(!exists($self -> resources -> {$key}) && $self -> parent) {
    $self -> parent -> get_resource($key);
  }
  else {
    $self -> resources -> {$key};
  }
}

sub set_resource {
  my($self, $key, $value) = @_;

  $self -> resources -> {$key} = $value;
}

sub set_var {
  my($self, $key, $val) = @_;

  $self -> vars -> {$key} = $val;
}

sub get_var {
  my($self, $key) = @_;

  if(!exists($self -> vars -> {$key})) {
    if($self -> has_parent) {
      return $self -> parent -> get_var($key);
    }
  }
  my $val = $self -> vars -> {$key};
  if(is_CodeRef($val)) {
    return $val->();
  }
  return $val;
}

sub process_node {
  my($self, $node) = @_;

  # text nodes pass through
  my $nodeType = $node -> nodeType;
  if($nodeType == XML_TEXT_NODE
      || $nodeType == XML_COMMENT_NODE
      || $nodeType == XML_CDATA_SECTION_NODE
    ) {
    return $node -> cloneNode;
  }
  elsif($node -> nodeType == XML_ELEMENT_NODE) {
    # we want to run the code associated with the node and replace the node
    # with the results
    my $local = $node -> localname;
    my $ns = $node -> namespaceURI;
    if($ns) {
      my $taglib = $self -> document -> taglibs -> {$ns};
      if($taglib) {
        return $taglib -> process_node($self, $node);
      }
    }
    else { # in HTML5
      # we need to descend
      my $collector = $node -> cloneNode;
      my $child = $node -> firstChild;
      while($child) {
        my $r = $self -> process_node( $child );
        $collector -> appendChild( $r ) if $r;
        $child = $child -> nextSibling;
      }
      return $collector;
    }
  }
}

1;
