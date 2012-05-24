package OokOok::Test::Schema;
use Moose;
use namespace::autoclean;
extends 'OokOok::Schema';

use JSON;

sub cat_init {
  my $self = shift;

  $self -> deploy;
  #$self -> prepopulate;
}

sub init {
  my $class = shift;

  my $self = $class->connect('dbi:SQLite:dbname=:memory:');
  $self -> cat_init;
  return $self;
}

sub load_fixture {
  my $s = shift;

  # load data from named file
  open my $fh, "<", $_[0] or die $@;
  local($/) = undef;
  my $json = <$fh>;
  close $fh;

  my $data = decode_json $json;

  my($resultset, $items);
  for my $resultset (qw/Project ProjectInstance Layout/) {
    $items = $data->{$resultset};
    if($items) {
      my $r = $s -> resultset($resultset);
      for my $item (@$items) {
        my $rec = $r -> new($item);
        $rec -> insert;
      }
    }
  }
}
