use MooseX::Declare;

class OokOok::Template::Processor {

  use OokOok::Template::Document;
  use OokOok::Template::Parser;
  use Carp;

  use Module::Load ();

  has c => ( is => 'rw', isa => 'Maybe[Object]', );

  has date => ( is => 'rw', lazy => 1,
    default => sub { $_[0] -> c -> stash -> {date} },
  );

  has namespaces => ( is => 'rw', isa => 'HashRef', default => sub { +{} } );

  has _taglibs => ( is => 'rw', isa => 'HashRef', default => sub { +{ } });

  has _parser => ( is => 'rw', isa => 'OokOok::Template::Parser' );

  method BUILD {
    for my $taglib (keys %{$self -> c -> config -> {'TagLibs'} -> {module} || {}}) {
      $self -> register_taglib($taglib);
    }

    $self -> _parser(
      OokOok::Template::Parser -> new(
        prefixes => [ keys %{$self -> namespaces} ],
      )
    );
  }

  method register_taglib ($taglib) {
    Module::Load::load $taglib;

    my $ns = $taglib -> meta -> namespace;
    if(!$ns) {
      # get NS from config
      $ns = $self -> c -> config -> {"TagLibs"} -> {module} -> {$taglib} -> {namespace};
      $taglib -> meta -> namespace($ns); # save it for later
    }
    if($ns) {
      $self -> _taglibs -> {$ns} = $taglib;
    }
  }

  method parse ($content) {
    my $dom = eval { $self -> _parser -> parse($content) };

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
      namespaces => $self -> namespaces,
    );

    $doc;
  }
}
