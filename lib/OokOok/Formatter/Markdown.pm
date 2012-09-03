use MooseX::Declare;

class OokOok::Formatter::Markdown {
  use Text::Markdown qw(markdown);

  method format ($text) { markdown($text); }
}
