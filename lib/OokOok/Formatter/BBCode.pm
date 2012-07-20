package OokOok::Formatter::BBCode;

use Moose;
use namespace::autoclean;
use Parse::BBCode::XHTML;

has _formatter => (
  is => 'ro',
  isa => 'Object',
  builder => '_build_formatter',
);

sub _build_formatter { Parse::BBCode::XHTML -> new }

sub format { 
  my $self = shift;
  my $tree = $self -> _formatter -> parse(shift);
  if($tree) {
    $self -> _formatter -> render_tree($tree);
  }
  else {
    '';
  }
}

1;
