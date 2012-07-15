package OokOok::Base::TagLibrary;

use Moose;
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
  my($self, $context, $node) = @_;

  # we want to pull out attributes and such based on needs of tag
  my $name = (split(":", $node -> nodeName, 2))[1];
  my $einfo = $self -> meta -> element( $name );
  return if !$einfo; # TODO: perhaps throw an error if not a defined element

  return if !$einfo -> {impl}; # Nothing to do, so don't do anything

  for my $ns (keys %{$einfo->{attributes}}) {
    for my $a (keys %{$einfo->{attributes}->{$ns}||{}}) {
      if($einfo->{attributes}->{$ns}->{$a} eq 'Str') {
        my $value = $node -> getAttributeNS($ns, $a);
        if(defined $value) {
          $context -> set_var( $a, $value );
        }
      }
    }
  }

  my $content;
  if($einfo -> {uses_content}) {
    $content = sub { $context -> localize -> process_node( $node ) };
  }
  else {
    $content = sub { '' };
  }

  $context -> set_var( 'content' => $context );

  my $impl = $einfo -> {impl};
  my $r;
  if(ref $impl) {
    $r = $einfo -> {impl} -> ($self, $context);
  }
  else {
    $r = $self -> $impl($context);
  }

  if(!ref $r) { # $r is a string
    if(!defined($einfo -> {escape_text}) || $einfo->{escape_text}) {
      $r = $node -> ownerDocument -> createTextNode( $r );
    }
    else {
      $r = XML::LibXML -> load_xml( string => $r ) -> documentElement;
    }
  }
  $r;
}

1;
