package OokOok::Declare::Symbols::TableEdition;

# ABSTRACT: Methods for defining an edition attached to an editioned result

use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;
use String::CamelCase qw(decamelize);
use DateTime::Format::Pg;
use JSON;

use Module::Load ();

use OokOok::Declare::Meta::TableEdition;

Moose::Exporter->setup_import_methods(
  with_meta => [
    'prop', 'owns_many', 'references', 'references_own',
  ],
  as_is => [ ],
  #also => 'Moose',
);

my $inflate_datetime = sub {
  my $date = DateTime::Format::Pg->parse_datetime(shift);
  $date -> set_formatter('OokOok::DateTime::Parser');
  $date;
};

my $deflate_datetime = sub {
  my $dt = shift;

  if(!ref $dt) {
    $dt = DateTime::Format::ISO8601 -> parse_datetime($dt);
  }
  DateTime::Format::Pg->format_datetime($dt);
};

sub init_meta {
  shift;
  my %args = @_;

  Moose->init_meta(%args);

  Moose::Util::MetaRole::apply_metaroles(
    for => $args{for_class},
    class_metaroles => {
      class => ['OokOok::Declare::Meta::TableEdition'],
    }
  );

  my $meta = $args{for_class}->meta;

  $meta -> superclasses('OokOok::Declare::Base::TableEdition');

  my $package = $args{for_class};
  my $nom = $package;
  $nom =~ s{^.*::}{};
  $nom = decamelize($nom);

  $meta -> foreign_key($nom . "_id");

  $package -> table($nom);
  $package -> add_columns(
    id => {
      data_type => "integer",
      is_auto_increment => 1,
      is_nullable => 0,
    },
    name => {
      data_type => 'varchar',
      is_nullable => 0,
      default_value => "",
      size => 255,
    },
    description => {
      data_type => 'text',
      is_nullable => 1,
    },
    created_on => {
      data_type => 'datetime',
      is_nullable => 0,
    },
    published_for => {
      data_type => 'tsrange', # timestamp range without time zone -- all UTC
      is_nullable => 1, # null indicates unpublished
    },
    closed_on => {
      data_type => 'datetime',
      is_nullable => 1,
    },
  );

  $package -> set_primary_key('id');

  $package -> inflate_column(created_on => {
     inflate => $inflate_datetime,
     deflate => $deflate_datetime,
  });

  $package -> inflate_column(closed_on => {
     inflate => $inflate_datetime,
     deflate => $deflate_datetime,
  });

  $package -> inflate_column(published_for => {
    inflate => sub {
      my $v = shift;
      $v =~ m{^[\[\(](.*)\s*,\s*(.*)[\]\)]};
      [ map { $_ -> $inflate_datetime } ($1, $2) ]; 
    },
    deflate => sub {
      my $v = shift;
      "[" . join(", ", map { $_ -> $deflate_datetime } @$v) . ")"
    },
  });

  $meta;
}

sub prop {
  my($meta, $method, %info) = @_;

  # PostgreSQL supports the json column type - we just add the inflate/deflate
  if($info{data_type} eq 'json') {
    $info{inflate} ||= sub { decode_json shift };
    $info{deflate} ||= sub { encode_json shift };
  }
  elsif($info{data_type} eq 'datetime') {
    $info{inflate} ||= $inflate_datetime;
    $info{deflate} ||= $deflate_datetime;
  }

  $meta -> {package} -> add_columns( $method, \%info );

  if($info{inflate} || $info{deflate}) {
    $meta -> {package} -> inflate_column( $method, {
      inflate => $info{inflate},
      deflate => $info{deflate}
    });
  }
}

sub owns_many {
  my($meta, $method, $class, %options) = @_;

  Module::Load::load($class);

  %options = (cascade_copy => 0, cascade_delete => 1, %options);

  $class -> add_columns( $meta -> foreign_key, {
    data_type => 'integer',
    is_nullable => 1,
  } );
  $class -> belongs_to(
    edition => $meta -> {package}, $meta -> foreign_key
  );

  $meta -> {package} -> has_many(
    $method, $class, $meta -> foreign_key, \%options
  );
}

sub references {
  my($meta, $prop_base, $class, %options) = @_;

  $meta -> {package} -> add_columns(
    $prop_base . "_id", {
      data_type => 'integer',
      is_nullable => 1,
    },
    $prop_base . "_date", {
      data_type => 'datetime',
      is_nullable => 1,
    }
  );

  $meta -> {package} -> inflate_column($prop_base . "_date" => {
     inflate => $inflate_datetime,
     deflate => $deflate_datetime,
  });

  $meta -> {package} -> belongs_to($prop_base, $class, $prop_base . "_id", \%options);
}

sub references_own {
  my($meta, $method, $class, %options) = @_;
  $meta -> {package} -> add_columns(
    $method . "_id", {
      data_type => 'integer',
      is_nullable => 1,
    },
  );
  $meta -> {package} -> belongs_to($method, $class, $method . "_id", \%options);
}

1;
