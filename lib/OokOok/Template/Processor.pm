package OokOok::Template::Processor;

use Moose;

use namespace::autoclean;
use OokOok::Template::Document;
use Carp;

use XML::LibXML;
use Module::Load ();

has c => (
  is => 'rw',
  isa => 'Maybe[Object]',
);

has date => (
  is => 'rw',
  lazy => 1,
  default => sub { $_[0] -> c -> stash -> {date} },
);

has _taglibs => (
  is => 'rw',
  isa => 'HashRef',
  default => sub { +{ } }
);

sub BUILD {
  my($self) = @_;

  for my $taglib (keys %{$self -> c -> config -> {'OokOok::Template::TagLibs'} -> {module} || {}}) {
    $self -> register_taglib($taglib);
  }
}

sub register_taglib {
  my($self, $taglib) = @_;

  Module::Load::load $taglib;

  my $ns = $taglib -> meta -> namespace;
  if(!$ns) {
    # get NS from config
    $ns = $self -> c -> config -> {"OokOok::Template::TagLibs"} -> {module} -> {$taglib} -> {namespace};
    $taglib -> meta -> namespace($ns); # save it for later
  }
  if($ns) {
    $self -> _taglibs -> {$ns} = $taglib;
  }
}

# we expect XML coming in - not free-form text
sub parse {
  my($self, $content) = @_;

  my $dom = eval { XML::LibXML -> load_xml( string => $content ) };

  if($@) {
    croak "Unable to parse document ($@):\n$content\n\n";
  }

  # we need to handle taglibs
  my %taglibs;
  foreach my $ns (keys %{$self -> _taglibs}) {
    $taglibs{$ns} = $self -> _taglibs -> {$ns} -> new(
      c => $self -> c,
      date => $self -> date,
    );
  }

  my $doc = OokOok::Template::Document -> new(
    content => $dom,
    taglibs => \%taglibs,
  );

  $doc;
}

1;
