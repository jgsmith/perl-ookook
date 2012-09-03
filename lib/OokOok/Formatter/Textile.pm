use MooseX::Declare;

class OokOok::Formatter::Textile {
  use Text::Textile qw(textile);

  has _textile => (
    is => 'ro',
    isa => 'Text::Textile',
    builder => '_build_textile',
  );

  method _build_textile {
    Text::Textile -> new(
      css => 1,
      charset => 'utf-8',
      trim_spaces => 1,
      char_encoding => 1,
      handle_quotes => 1,
    );
  }

  method format ($text) { $self -> _textile -> process($text); }
}
