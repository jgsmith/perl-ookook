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

use MooseX::Types::Moose qw/Object/;

use OokOok::Util::DB;

*prop = \&OokOok::Util::DB::prop;

Moose::Exporter->setup_import_methods(
  with_meta => [
    'prop', 'owns_many', 'references', 'references_own',
  ],
  as_is => [ ],
  #also => 'Moose',
);

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

  prop($meta, id => (
    data_type => 'integer',
    is_auto_increment => 1,
    is_nullable => 0,
  ));

  $package -> set_primary_key('id');

  prop($meta, name => (
    data_type => 'varchar',
    is_nullable => 0,
    default_value => "",
    size => 255,
  ));

  prop($meta, description => (
    data_type => 'text',
    is_nullable => 1,
  ));

  prop($meta, created_on => (
    data_type => 'datetime',
    is_nullable => 0,
  ));

  prop($meta, published_for => (
    data_type => 'tsrange', # timestamp range without time zone -- all UTC
    is_nullable => 1, # null indicates unpublished
  ));

  $meta;
}

sub owns_many {
  my($meta, $method, $class, %options) = @_;

  Module::Load::load($class);

  %options = (cascade_copy => 0, cascade_delete => 1, %options);

  $class -> add_columns( $meta -> foreign_key, {
    data_type => 'integer',
    is_nullable => 1,
    is_foreign_key => 1,
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

  prop($meta, $prop_base . "_id",
    data_type => 'integer',
    is_foreign_key => 1,
    is_nullable => 1,
  );

  prop($meta, $prop_base . "_date",
    data_type => 'datetime',
    is_nullable => 1,
  );

  $meta -> {package} -> belongs_to($prop_base, $class, $prop_base . "_id", \%options);
}

sub references_own {
  my($meta, $method, $class, %options) = @_;
  $meta -> {package} -> add_columns(
    $method . "_id", {
      is_foreign_key => 1,
      data_type => 'integer',
      is_nullable => 1,
    },
  );
  $meta -> {package} -> belongs_to($method, $class, $method . "_id", \%options);
}

1;
