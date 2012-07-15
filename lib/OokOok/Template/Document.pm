package OokOok::Template::Document;

use Moose;
use XML::LibXML;
use OokOok::Template::Context;

use namespace::autoclean;

has content => (
  is => 'ro',
  required => 1,
  isa => 'Object', # should be a parsed XML document
);

has taglibs => (
  is => 'ro',
  isa => 'HashRef',
  default => sub { +{ } },
);

sub render {
  my($self, $parent_context) = @_;

  # we want to run through the document looking for elements that are
  # provided by taglibs - we want to work from the top down - kind of like
  # an XSLT

  my $rendering = XML::LibXML::Document -> new;
  my $context = OokOok::Template::Context -> new(
    parent => $parent_context,
    document => $self,
  );

  $rendering -> setDocumentElement( 
    $context -> process_node( 
      $self -> content -> documentElement 
    ) 
  );
  
  my $r = $rendering -> toString;

  #
  # we get rid of any <?xml...?> element at the beginning since we'll be
  # embedding this in an HTML document
  #
  $r =~ s{^\s*<\?xml\b.*?\?>\s*}{};
  $r;
}

1;
