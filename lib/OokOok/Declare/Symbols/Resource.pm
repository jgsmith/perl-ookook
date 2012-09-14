package OokOok::Declare::Symbols::Resource;

# ABSTRACT: Provides sugar and metaclass for defining REST resource classes

use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;

use Module::Load ();
use String::CamelCase qw(decamelize);

use OokOok::Declare::Meta::Resource;

use namespace::autoclean;
use 5.10.0;

Moose::Exporter->setup_import_methods(
  with_meta => [ 'prop', 'has_many', 'belongs_to', 'collection_class', 'has_a', 'resource_name' ],
  as_is     => [ ],
  #also      => 'Moose',
);

sub init_meta {
  shift;
  my %args = @_;

  Moose->init_meta(%args);

  Moose::Util::MetaRole::apply_metaroles(
     for             => $args{for_class},
     class_metaroles => {
       class => ['OokOok::Declare::Meta::Resource'],
     }
  );

  my $meta = $args{for_class}->meta();

  my $nom = $args{for_class};
  $nom =~ s{^.*::}{};
  $nom = decamelize($nom);
  $meta -> resource_name($nom);

  return $meta;
}

=method resource_name (Str $name)

Defines the name of the resource if the default isn't reasonable.

The default resource name is the decamelized version of the final portion
of the resource package name. For example, the resource name for the
OokOok::Resource::SomethingOrOther resource is C<something_or_other>.

=cut

sub resource_name {
  my($meta, $name) = @_;

  $meta -> resource_name($name);
}

=method collection_class (ClassName $class)

Sets the class representing a collection of the resource. By default, this
is the same package name as the resource but with C<::Resource::> replaced
with C<::Collection::>.

The collection class will be loaded automatically. The program will die if
the class will not load.

=cut

sub collection_class {
  my($meta, $class) = @_;

  eval { Module::Load::load($class) };
  if($@) {
    warn "Unable to load $class as collection class for ", $meta -> {package}, "\n";
  }
  else {
    $meta -> resource_collection_class($class);
  }
}

=method prop (Str $name, %options)

Adds a property to the resource class. The following options are recognized:

=for :list
* is => (ro|rw)
Determines if the property is C<ro> (readonly) or C<rw> (read/write).
* required => (0|1)
If required, the property must be supplied when a resource is created, and
the property may not be set to C<undef> or an empty string.
* date => sub { ... }
* source => sub { ... }
Returns the value of the property. If this option is not provided, then
the resource class will default to the equivalent of

 sub { $_[0] -> source -> $name }

=cut

sub prop {
  my($meta, $name, %props) = @_;

  $meta -> add_prop( $name, %props );
}

=method belongs_to (Str $key, ClassName $resource_class, %config)

=cut

sub belongs_to {
  my($meta, $key, $resource_class, %config) = @_;

  eval { Module::Load::load($resource_class) };
  if($@) {
    warn "Unable to load $resource_class for $key\n";
  }
  else {
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
}

=method has_a (Str $key, ClassName $resource_class, %config)

=cut

sub has_a {
  my($meta, $key, $resource_class, %config) = @_;

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

  $meta -> add_hasa( $key, (
    %config,
    isa => $resource_class,
    source => $method,
  ) );
}

=method has_many (Str $key, ClassName $resource_class, %config)

=cut

sub has_many {
  my($meta, $key, $resource_class, %config) = @_;

  eval { Module::Load::load($resource_class) };

  if($@) {
    warn "Unable to load $resource_class for $key\n";
  }
  else {
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
}

1;

__END__
