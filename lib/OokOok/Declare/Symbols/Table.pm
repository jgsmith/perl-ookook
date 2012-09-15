package OokOok::Declare::Symbols::Table;

# ABSTRACT: Methods to define a database schema result

# default props:
#   id

# optional:
#   with_uuid
# 

use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;
use String::CamelCase qw(decamelize);
use Lingua::EN::Inflect qw(PL_N);

use MooseX::Types::Moose qw(ArrayRef);

use Module::Load ();

use OokOok::Declare::Meta::Table;

Moose::Exporter->setup_import_methods(
  with_meta => [
    'prop', 'owns_many', 'with_uuid', 'references',
  ],
  as_is => [ ],
  #also => 'Moose',
);

sub init_meta {
  shift;
  my %args = @_;

  Moose->init_meta(%args);

  Moose::Util::MetaRole::apply_metaroles(
    for             => $args{for_class},
    class_metaroles => {
      class => ['OokOok::Declare::Meta::Table'],
    }
  );

  my $meta = $args{for_class}->meta;

  $meta -> superclasses("OokOok::Declare::Base::Table");

  my $package = $args{for_class};
  my $nom = $package;
  $nom =~ s{^.*::}{};
  $nom = decamelize($nom);

  $meta -> foreign_key($nom . "_id");

  # set up defaults
  #$package -> load_components("InflateColumn::DateTime");
  $package -> table($nom);
  $package -> add_columns(
    id => {
      data_type => "integer",
      is_auto_increment => 1,
      is_nullable => 0,
    },
  );

  $package -> set_primary_key('id');

  return $meta;
}

sub with_uuid {
  my($meta) = @_;

  $meta -> {package} -> add_columns(
    uuid => {
      data_type => 'char',
      is_nullable => 0,
      size => 20,
    },
  );
  $meta -> {package} -> add_unique_constraint(['uuid']);
}

sub prop {
  my($meta, $method, %info) = @_;

  $meta -> {package} -> add_columns( $method, \%info );

  if($info{inflate} || $info{deflate}) {
    $meta -> {package} -> inflate_column( $method, {
      inflate => $info{inflate},
      deflate => $info{deflate}
    });
  }

  if($info{unique}) {
    if(is_ArrayRef($info{unique})) {
      $meta -> {package} -> add_unique_constraint([@{$info{unique}}, $method]);
    }
    else {
      $meta -> {package} -> add_unique_constraint([$method]);
    }
  }
}

sub owns_many {
  my($meta, $method, $class, %options) = @_;

  eval { Module::Load::load($class) };

  if($@) {
    warn "Unable to load $class for $method\n";
  }
  else {
    $class -> add_columns( $meta -> foreign_key, {
      data_type => 'integer',
      is_nullable => 1,
    } );
    $class -> belongs_to(
      $meta -> {package} -> table, $meta -> {package}, $meta -> foreign_key
    );
    $meta -> {package} -> has_many(
      $method, $class, $meta -> foreign_key, \%options
    );
  }
}

sub references {
  my($meta, $method, $class, %options) = @_;

  eval { Module::Load::load($class) };

  if($@) {
    warn "unable to load $class for $method\n";
  }
  else {
    $meta -> {package} -> add_columns( $class -> meta -> foreign_key, {
      data_type => 'integer',
      is_nullable => 1,
    } );
    $meta -> {package} -> belongs_to(
      $method, 
      $class, 
      $class -> meta -> foreign_key, 
    );
    $class -> has_many(
      PL_N($meta -> {package} -> table), 
      $meta -> {package}, 
      $class -> meta -> foreign_key,
      \%options
    );
  }
}

1;
