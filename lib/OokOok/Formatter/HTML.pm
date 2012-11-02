use MooseX::Declare;

# PODNAME: OokOok::Formatter::HTML

# ABSTRACT: Null formatter for HTML

class OokOok::Formatter::HTML {

=method extension

 html

=cut

  method extension { 'html' }

  method editor_mode { 'html' }

=method format (Str $text)

Returns the text as-is since this is a no-op formatter.

=cut

  method format (Str $text) { $text; }

}
