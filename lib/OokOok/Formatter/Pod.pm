use MooseX::Declare;

# PODNAME: OokOok::Formatter::Pod

# ABSTRACT: Format Pod as HTML

class OokOok::Formatter::Pod {
  use Pod::Simple::HTML;
  use Pod::Checker;
  use IO::String;

  has _formatter => (
    is => 'rw',
    isa => 'Pod::Simple::HTML',
    builder => '_build_formatter',
  );

  method _build_formatter {
    Pod::Simple::HTML -> new(
    );
  }

=method extension

 pod

=cut

  method extension { 'pod' }

=method format (Str $text)

Formats the provided text as Pod, returning HTML.

=cut

  method format (Str $text) { 
    $self -> _formatter -> output_string(\my $result);

    $self -> _formatter -> parse_string_document( $text );

    $result =~ m{<!-- start doc -->\s*(.*)<!-- end doc -->}s;
    return $1;
  }

=method validate (Str $text)

Checks the provided text for validity. Returns a list of errors, if any.

=cut

  method validate (Str $text) {
    my $in = IO::String -> new($text);
    my $out = IO::String -> new;

    my $syntax_okay = podchecker($in, $out);

    return if $syntax_okay;

    return $out -> string_ref;
  }

=head1 SEE ALSO

=for :list
* L<Text::Markdown>

=cut

}
