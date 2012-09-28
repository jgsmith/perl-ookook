use CatalystX::Declare;

# PODNAME: OokOok::Declare::Meta::TagLibrary

# ABSTRACT: Tracks meta-information about tag library classes

role OokOok::Declare::Meta::TagLibrary {
  has taglib_namespace => (
    is => 'rw',
    isa => 'Str',
  );

  has elements => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { +{} },
  );

  has _documentation => (
    is => 'rw',
    isa => 'Str',
    default => '',
  );

  method set_documentation (Str $d) {
    $self -> _documentation($d);
  }

  method add_element (Str $tag, %config) {
    if($self -> _documentation ne '') {
      $config{documentation} = $self -> _documentation;
      $self -> _documentation('');
    }
    $self -> elements -> {$tag} = \%config;
  }

  method element (Str $tag) {
    $self -> elements -> {$tag}
  }

  method documentation (Str $prefix = 'xx') {
    # gather docs and return markdown-formatted text (but not transformed
    # to html yet so we can add wrapper text elsewhere)

    my $doc = '';
    for my $el (sort keys %{$self -> elements}) {
      $doc .= "### $el\n\n";

      if($self -> elements -> {$el} -> {documentation}) {
        my $d = $self -> elements -> {$el} -> {documentation};
        $doc .= join($prefix.":".$el, split("%tag%", $d));
      }
      else {
        $doc .= "(No documentation)";
      }
      $doc .= "\n\n";
    }

    $doc = join($prefix, split("%ns%", $doc));
  }
}
