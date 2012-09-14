package OokOok::DateTime::Parser;

use Moose;

use DateTime::Format::Builder (
  parsers => {
    parse_datetime => {
      params => [ qw(year month day hour minute second) ],
      regex => qr/^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$/
    }
  },
);

sub format_datetime {
  my($self, $dt) = @_;

  $dt -> ymd('') . $dt->hms('');
}

no Moose;

1;
