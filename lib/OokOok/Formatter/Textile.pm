use MooseX::Declare;

# PODNAME: OokOok::Formatter::Textile

# ABSTRACT: Format Textile as HTML

class OokOok::Formatter::Textile {
  use Text::Textile qw(textile);

  has _textile => (
    is => 'ro',
    isa => 'Text::Textile',
    builder => '_build_textile',
  );

  method _build_textile {
    my $ob = Text::Textile -> new(
      charset => 'utf-8',
      trim_spaces => 1,
      char_encoding => 1,
      handle_quotes => 1,
    );
    $ob -> css(1);
    $ob;
  }

=method extension

 textile

=cut

  method extension { 'textile' }

=method format (Str $text)

Formats the given text using Textile, returning HTML.

=cut

  method format (Str $text) { $self -> _textile -> process($text); }
}

=head1 SEE ALSO

=for :list
* L<Text::Textile>
