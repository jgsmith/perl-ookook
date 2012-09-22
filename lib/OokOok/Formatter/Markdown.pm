use MooseX::Declare;

# PODNAME: OokOok::Formatter::Markdown

# ABSTRACT: Format Markdown as HTML

class OokOok::Formatter::Markdown {
  use Text::MultiMarkdown qw(markdown);

  has _formatter => (
    is => 'rw',
    isa => 'Text::MultiMarkdown',
    builder => '_build_formatter',
  );

  method _build_formatter {
    Text::MultiMarkdown -> new(
      strip_metadata => 1,
      use_metadata => 0,
    );
  }

=method extension

 md

=cut

  method extension { 'md' }

=method format (Str $text)

Formats the provided text as Markdown, returning HTML.

=cut

  method format (Str $text) { $self -> _formatter -> markdown($text); }
}

=head1 SEE ALSO

=for :list
* L<Text::Markdown>
