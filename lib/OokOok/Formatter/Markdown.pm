use MooseX::Declare;

# PODNAME: OokOok::Formatter::Markdown

# ABSTRACT: Format Markdown as HTML

class OokOok::Formatter::Markdown {
  use Text::Markdown qw(markdown);

=method format (Str $text)

Formats the provided text as Markdown, returning HTML.

=cut

  method format (Str $text) { markdown($text); }
}

=head1 SEE ALSO

=for :list
* L<Text::Markdown>
