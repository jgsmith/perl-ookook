use MooseX::Declare;

class OokOok::Formatter::HTML {

  # we return HTML, so we just pass things through as-is
  method format ($text) { $text; }

}
