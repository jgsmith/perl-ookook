package OokOok::Util::DB;

# ABSTRACT: Utility routines used in various places

use DateTime::Format::ISO8601;
use DateTime::Format::Pg;
use DateTime::Span;
use OokOok::DateTime::Parser;

use JSON;

use MooseX::Types::Moose qw/Object/;

sub inflate_datetime {
  my $dt = shift;
  return unless defined $dt && $dt ne '';
  my $date = DateTime::Format::Pg->parse_datetime($dt);
  $date -> set_formatter('OokOok::DateTime::Parser');
  $date;
}

sub deflate_datetime {
  my $dt = shift;

  return unless defined $dt;
  if(!ref $dt) {
    $dt = DateTime::Format::ISO8601 -> parse_datetime($dt);
  }
  if(is_Object($dt)) {
    $dt = DateTime::Format::Pg->format_datetime($dt);
  }
  $dt;
}

sub inflate_tsrange {
  return unless defined $_[0];
  $_[0] =~ m{^[\[\(]"?([^"]*)"?\s*,\s*"?([^"]*)"?[\]\)]};
  my $dts = [ map { $_ ? inflate_datetime($_) : undef } ($1, $2) ];
  my %info;
  if(defined($dts -> [0])) {
    $info{start} = $dts->[0];
  }
  if(defined($dts -> [1])) {
    $info{before} = $dts -> [1];
  }
  DateTime::Span -> from_datetimes(%info);
}

sub deflate_tsrange {
  return undef unless defined $_[0];

  my $v = ("'[" . join(",", map { deflate_datetime($_) || '' } (
    $_[0] -> start,
    $_[0] -> end
  )) . ")'::tsrange");

  if($v eq "'[)'::tsrange") {
    return undef;
  }
  return \$v;
}

sub prop {
  my($meta, $method, %info) = @_;

  # PostgreSQL supports the json column type - we just add the inflate/deflate
  if($info{data_type} eq 'json') {
    $info{inflate} ||= sub { decode_json shift };
    $info{deflate} ||= sub { encode_json shift };
  }
  elsif($info{data_type} eq 'datetime') {
    $info{inflate} ||= \&OokOok::Util::DB::inflate_datetime;
    $info{deflate} ||= \&OokOok::Util::DB::deflate_datetime;
  }
  elsif($info{data_type} eq 'tsrange') {
    $info{inflate} ||= \&OokOok::Util::DB::inflate_tsrange;
    $info{deflate} ||= \&OokOok::Util::DB::deflate_tsrange;
  }
  elsif($info{data_type} eq 'varchar') {
    $info{data_type} = 'text';
  }

  $meta -> {package} -> add_columns( $method, \%info );

  #if($info{data_type} eq 'tsrange') {
  #  # add index on range
  #  # CREATE INDEX reservation_idx ON reservation USING gist (during);
  #  $meta -> {package} -> add_index(
  #    name => $method . '_gist',
  #    fields => [ "gist ($method)" ],
  #  );
  #}

  if($info{inflate} || $info{deflate}) {
    $meta -> {package} -> inflate_column( $method, {
      inflate => $info{inflate},
      deflate => $info{deflate}
    });
  }
}

1;
