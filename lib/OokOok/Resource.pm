package OokOok::Resource;

use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;

use Module::Load ();

use OokOok::Base::Resource;
use OokOok::Meta::Resource;

use namespace::autoclean;
use 5.10.0;

Moose::Exporter->setup_import_methods(
  with_meta => [ 'prop', 'has_many', 'belongs_to', 'collection_class' ],
  as_is     => [ ],
  also      => 'Moose',
);

sub init_meta {
  shift;
  my %args = @_;

  Moose->init_meta(%args);

  Moose::Util::MetaRole::apply_metaroles(
     for             => $args{for_class},
     class_metaroles => {
       class => ['OokOok::Meta::Resource'],
     }
  );

  my $meta = $args{for_class}->meta();

  $meta -> superclasses("OokOok::Base::Resource");

  return $meta;
}

sub collection_class {
  my($meta, $class) = @_;

  Module::Load::load($class);
  $meta -> resource_collection_class($class);
}

sub prop {
  my($meta, $name, %props) = @_;

  $meta -> add_prop( $name, %props );
}

sub belongs_to {
  my($meta, $key, $resource_class, %config) = @_;

  Module::Load::load($resource_class);

  my $method;

  if(!$config{source}) {
    $method = sub { $_[0] -> source -> $key };
  }
  elsif(!ref $config{source}) {
    my $mkey = $config{source};
    $method = sub { $_[0] -> source -> $mkey };
  }
  else {
    $method = $config{source};
  }

  $meta -> add_owner( $key, 
    %config,
    isa => $resource_class,
    source => $method,
  );
}

sub has_many {
  my($meta, $key, $resource_class, %config) = @_;

  Module::Load::load($resource_class);

  my $method;

  if(!$config{source}) {
    $method = sub { $_[0] -> source -> $key };
  }
  elsif(!ref $config{source}) {
    my $mkey = $config{source};
    $method = sub { $_[0] -> source -> $mkey };
  }
  else {
    $method = $config{source};
  }


  $meta -> add_embedded( $key, (
    %config,
    isa => $resource_class,
    source => $method,
    default => sub {
      my($self) = @_;
      [ map { $resource_class -> new(
        c => $self -> c,
        source => $_,
      ) } $method->($self) ];
    },
  ));
}

1;

__END__
