use MooseX::Declare;

# PODNAME: OokOok::Formatter::BBCode

# ABSTRACT: Format BBCode as HTML

class OokOok::Formatter::BBCode {
  use Parse::BBCode;

  has _formatter => (
    is => 'ro',
    isa => 'Object',
    builder => '_build_formatter',
  );

  method _build_formatter { 
    Parse::BBCode -> new(
      close_open_tags => 1,
      url_finder => 0,
      strict_attributes => 0,
      attribute_quote => q/'"/,
    );
  }

=method format (Str $text)

Formats the provided BBCode string as HTML.

=cut

  method format (Str $text) { $self -> _formatter -> render($text); }

}

=head1 SEE ALSO

=for :list
* L<Parse::BBCode>
