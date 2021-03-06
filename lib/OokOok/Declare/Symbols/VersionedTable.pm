package OokOok::Declare::Symbols::VersionedTable;

# ABSTRACT: Declarative methods for versioned database results

use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;
use String::CamelCase qw(decamelize);
use Lingua::EN::Inflect qw(PL_N);
use JSON;

use Module::Load ();

use OokOok::Declare::Base::VersionedTable;
use OokOok::Declare::Meta::VersionedTable;
use OokOok::Declare::Base::TableVersion;

Moose::Exporter->setup_import_methods(
  with_meta => [ 'references', 'owns_many' ],
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
      class => ['OokOok::Declare::Meta::VersionedTable'],
    }
  );

  my $meta = $args{for_class}->meta;

  $meta -> superclasses("OokOok::Declare::Base::VersionedTable");

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
  );

  $package -> add_unique_constraint(['uuid']);

  $package -> set_primary_key('id');

  # This avoids an extraneous warning when testing with Dist::Zilla
  return $meta if $package eq 'Test::UseAllModules';

  my $version_pkg = $package . "Version";
  eval { Module::Load::load($version_pkg) };
  if($@) {
    warn "Unable to load $version_pkg: $@\n";
  }
  else {
    $version_pkg -> add_columns( $meta -> foreign_key, {
      data_type => 'integer',
      is_foreign_key => 1,
      is_nullable => 0,
    });
    $version_pkg -> belongs_to(
      $nom, $package, $meta -> foreign_key
    );
    $package -> has_many(
      versions => $version_pkg, $meta -> foreign_key
    );
    $version_pkg -> meta -> add_method( owner => sub {
      $_[0] -> $nom
    } );
  }

  return $meta;
}

sub references {
  my($meta, $method, $class) = @_;

  $meta -> {package} -> add_columns(
    $method . "_id", {
      data_type => 'integer',
      is_foreign_key => 1,
      is_nullable => 1,
    },
  );

  $meta -> {package} -> belongs_to($method, $class, $method."_id", {
    cascade_delete => 0,
    cascade_copy => 0,
  });
  $class -> has_many(
    PL_N($meta -> {package} -> table), $meta -> {package},
    $class -> meta -> foreign_key
  );
}

sub owns_many {
  my($meta, $method, $class, %options) = @_;

  eval { Module::Load::load($class) };

  if($@) {
    warn "Unable to load $class for $method\n";
  }
  else {
    %options = (cascade_copy => 0, cascade_delete => 1, %options);

    $class -> add_columns( $meta -> foreign_key, {
      data_type => 'integer',
      is_foreign_key => 1,
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

1;

__END__
