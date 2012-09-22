package OokOok::Declare::Symbols::EditionedTable;

# ABSTRACT: Declarative methods for editioned database results

# has editions
# has uuid

use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;
use String::CamelCase qw(decamelize);

use Module::Load ();

use OokOok::Declare::Meta::EditionedTable;
use OokOok::Declare::Base::TableEdition;

Moose::Exporter->setup_import_methods(
  with_meta => [
    'owns_many', 'has_editions', 'prop',
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
      class => ['OokOok::Declare::Meta::EditionedTable'],
    }
  );

  my $meta = $args{for_class}->meta;

  $meta -> superclasses("OokOok::Declare::Base::EditionedTable");

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
    uuid => {
      data_type => "char",
      is_nullable => 0,
      size => 20,
    },
    board_id => {
      data_type => "integer",
      is_nullable => 1,
    },
  );

  $package -> add_unique_constraint(['uuid']);

  $package -> set_primary_key('id');

  $package -> belongs_to(
    board => "OokOok::Schema::Result::Board", "board_id"
  );

  return $meta;
}

sub owns_many {
  my($meta, $method, $class, %options) = @_;

  eval { Module::Load::load($class) };
  if($@) {
    warn "Unable to load $class for $method\n";
  }
  else {
    $class -> add_columns( $meta -> foreign_key, {
      data_type => "integer",
      is_nullable => 1,
    } );
    my $nom = $meta -> {package} -> table;
    $class -> belongs_to(
      $nom, $meta -> {package}, $meta -> foreign_key
    );
    $meta -> {package} -> has_many(
      $method, $class, $meta -> foreign_key, \%options
    );
    $class -> meta -> add_method( owner => sub { $_[0] -> $nom } );
  }
}

sub has_editions {
  my($meta, $class) = @_;

  if(!$class) {
    $class = $meta -> {package} . "Edition";
  }
  eval { Module::Load::load($class) };
  if($@) {
    warn "Unable to load editions class $class\n";
  }
  else {
    $class -> add_columns( $meta -> foreign_key, {
      data_type => "integer",
      is_nullable => 0,
    } );
    my $nom = $meta -> {package} -> table;
    $class -> belongs_to(
      $nom, $meta -> {package}, $meta -> foreign_key
    );
    $meta -> {package} -> has_many(
      editions => $class, $meta -> foreign_key
    );
    $class -> meta -> add_method( owner => sub { $_[0] -> $nom } );
  }
}

sub prop {
  my($meta,  $method, %info) = @_;

  $meta -> {package} -> add_columns( $method, \%info );

  if($info{inflate} || $info{deflate}) {
    $meta -> {package} -> inflate_column( $method, {
      inflate => $info{inflate},
      deflate => $info{deflate}
    });
  }
}

1;