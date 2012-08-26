package OokOok::Util::XML;

use MooseX::Types::Moose qw(HashRef CodeRef);
use XML::LibXML;
use Carp::Always;

sub ELEMENT {
  my($name, $dom, $attrs, @children) = @_;

  my $el = XML::LibXML::Element->new($name);
  my $cel;
  if(!is_HashRef($attrs)) {
    unshift @children, $attrs;
    $attrs = {};
  }
  foreach my $k (keys %$attrs) {
    $el -> setAttribute( $k, $attrs -> {$k} );
  }
  foreach my $child (@children) {
    if(ref $child) {
      $cel = $child->($dom);
    }
    else {
      $cel = XML::LibXML::Text -> new( $child );
    }
    $el -> appendChild($cel) if $cel;
  }

  return $el;
}

sub xml {
  my($dom, $attrs, @children) = @_;
  my $rootEl;
  if(!ref($dom)) {
    my $rootElName = $dom;
    $dom = XML::LibXML::Document -> new; # new document
    $rootEl = $dom -> createElement($rootElName);
    $dom -> setDocumentElement($rootEl);
    if(!is_HashRef($attrs)) {
      unshift @children, $attrs;
      $attrs = {};
    }
    foreach my $k (keys %$attrs) {
      $el -> setAttribute( $k, $attrs -> {$k} );
    }
  }
  elsif(is_CodeRef($dom)) {
    unshift @children, $dom;
    $dom = XML::LibXML::Document -> new; # new document
  }
  elsif($dom -> isa("XML::LibXML::Node")) {
    $rootEl = $dom;
  }
  elsif($dom -> isa("XML::LibXML::Document")) {
    $rootEl = $dom -> getDocumentElement();
  }
 
  my $cel;
  if(!is_HashRef($attrs)) {
    unshift @children, $attrs;
    $attrs = {};
  }
  foreach my $child (@children) {
    if(ref $child) {
      $cel = $child->($rootEl);
    }
    elsif($rootEl) {
      $cel = XML::LibXML::Text -> new( $child );
    }

    if($cel) {
      if(!$rootEl) {
        $dom -> setDocumentElement($cel);
        return $dom;
      }
      else {
        $rootEl -> appendChild($cel);
      }
    }
  }
  return $dom;
}

sub import {
  my $pkg = shift;
  my $callpkg = caller(0);

  # imported names need to be xml element names
  while(@_) {
    my $elName = shift;
    if($elName eq 'xml') {
      *{"$callpkg\::xml"} = \&xml;
    }
    else {
      *{"$callpkg\::$elName"} = sub {
        my @args = @_;
        return sub { ELEMENT($elName, @_, @args) }
      };
    }
  }
}

=head1 Example

xml(bar => (
  el('foo', 'bar')
));

results in

<bar>
  <foo>bar</foo>
</bar>

=cut

1;
