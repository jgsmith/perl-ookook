package OokOok::ResultVersion;

use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;
use String::CamelCase qw(decamelize);

use Module::Load ();

use OokOok::Base::ResultVersion;
use OokOok::Meta::ResultVersion;

Moose::Exporter->setup_import_methods(
  with_meta => [
    'prop', 'owns_many',
  ],
  as_is => [ ],
  also => 'Moose',
);

sub init_meta {
  shift;
  my %args = @_;

  Moose->init_meta(%args);

  Moose::Util::MetaRole::apply_metaroles(
    for => $args{for_class},
    class_metaroles => {
      class => ['OokOok::Meta::ResultVersion'],
    }
  );

  my $meta = $args{for_class}->meta;

  $meta -> superclasses('OokOok::Base::ResultVersion');

  my $package = $args{for_class};
  my $nom = $package;
  $nom =~ s{^.*::}{};
  $nom = decamelize($nom);

  $meta -> foreign_key($nom . "_id");

  $package -> load_components("InflateColumn::DateTime");
  $package -> table($nom);
  $package -> add_columns(
    id => {
      data_type => "integer",
      is_auto_increment => 1,
      is_nullable => 0,
    },
  );

  $package -> set_primary_key('id');

  $meta;
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

sub owns_many {
  my($meta, $method, $class, %options) = @_;

  Module::Load::load($class);

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

1;