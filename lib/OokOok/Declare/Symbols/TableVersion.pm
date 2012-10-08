package OokOok::Declare::Symbols::TableVersion;

# ABSTRACT: Methods to define a version of a versioned result

use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;
use String::CamelCase qw(decamelize);
use JSON;

use Module::Load ();

use OokOok::Declare::Meta::TableVersion;
use OokOok::Declare::Base::TableVersion;

Moose::Exporter->setup_import_methods(
  with_meta => [
    'prop', 'owns_many', 'is_publishable', 'references', 'references_own',
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
      class => ['OokOok::Declare::Meta::TableVersion'],
    }
  );

  my $meta = $args{for_class}->meta;

  $meta -> superclasses('OokOok::Declare::Base::TableVersion');

  my $package = $args{for_class};
  my $nom = $package;
  $nom =~ s{^.*::}{};
  $nom = decamelize($nom);

  $meta -> foreign_key($nom . "_id");

  #$package -> load_components("InflateColumn::DateTime");
  $package -> table($nom);
  $package -> add_columns(
    id => {
      data_type => "integer",
      is_auto_increment => 1,
      is_nullable => 0,
    },
#    published_for => {
#      data_type => "tsrange",
#      is_nullable => 0,
#    },
  );

  $package -> set_primary_key('id');

#  $package -> inflate_column(published_for => {
#    inflate => sub {
#      my $v = shift;
#      $v =~ m{^[\[\(](.*)\s*,\s*(.*)[\]\)]};
#      [ map { $_ -> $inflate_datetime } ($1, $2) ];
#    },
#    deflate => sub {
#      my $v = shift;
#      "[" . join(", ", map { $_ -> $deflate_datetime } @$v) . ")"
#    },
#  });

  $meta;
}

sub is_publishable {
  my($meta) = @_;

  prop($meta, 
    status => (
      data_type => 'integer',
      default_value => 0,
      is_nullable => 0,
    )
  );
}

sub prop {
  my($meta,  $method, %info) = @_;

  # PostgreSQL supports the json column type - we just add the inflate/deflate
  if($info{data_type} eq 'json') {
    $info{inflate} ||= sub { decode_json shift };
    $info{deflate} ||= sub { encode_json shift };
  }
  elsif($info{data_type} eq 'datetime') {
    $info{inflate} ||= $inflate_datetime;
    $info{deflate} ||= $deflate_datetime;
  }
  elsif($info{data_type} eq 'varchar') {
    $info{data_type} = 'text';
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

  eval { Module::Load::load($class) };

  if($@) {
    warn "Unable to load $class for $method\n";
  }
  else {
    %options = (cascade_copy => 1, cascade_delete => 1, %options);

    $class -> add_columns( $meta -> foreign_key, {
      data_type => 'integer',
      is_nullable => 1,
    } );
    $class -> belongs_to(
      $meta->{package} -> table, $meta -> {package}, $meta -> foreign_key
    );

    $meta -> {package} -> has_many(
      $method, $class, $meta -> foreign_key, \%options
    );
  }
}

=method references (Str $method, ClassName $class, %options)

Sets up a temporal relationship with another table class.

N.B.: This will not provide a simple method for setting the two
columns automatically since the datetime value may not be the same
as any of the explicit datetime values in the target row.

The following two snippets are equivalent:

 references foo => 'OokOok::Schema::Result::Foo';

and

 $CLASS -> add_columns(
   foo_id => {
     data_type => 'integer',
     is_nullable => 1,
   },
   foo_date => {
     data_type => 'datetime',
     is_nullable => 1,
   }
 );
 
 $CLASS -> inflate_column(foo_date => {
   inflate => ...,
   deflate => ...
 });
 
 $CLASS -> belongs_to(foo => 'OokOok::Schema::Result::Foo', foo_id);

 $CLASS -> add_method( foo_version => sub { ... } );

=cut

sub references {
  my($meta, $prop_base, $class, %options) = @_;

  my $prop_date = $prop_base . "_date";

  $meta -> {package} -> add_columns(
    $prop_base . "_id", {
      data_type => 'integer',
      is_nullable => 1,
    },
    $prop_date, {
      data_type => 'datetime',
      is_nullable => 1,
    }
  );

  $meta -> {package} -> inflate_column($prop_date, {
    inflate => $inflate_datetime,
    deflate => $deflate_datetime,
  });

  $meta -> {package} -> belongs_to($prop_base, $class, $prop_base . "_id", \%options);

  $meta -> {package} -> add_method( $prop_base . "_version", sub {
    $_[0] -> $prop_base -> version_for_date( $_[0] -> $prop_date );
  });
}

=method references_own (Str $method, ClassName $class, %options)

Sets up a non-temporal relationship with another table class.

The following two snippets are equivalent:

 references_own foo => 'OokOok::Schema::Result::Foo';

and

 $CLASS -> add_columns(
   foo_id => {
     data_type => 'integer',
     is_nullable => 1,
   }
 );
 
 $CLASS -> belongs_to( foo => 'OokOok::Schema::Result::Foo', 'foo_id' );

=cut

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
