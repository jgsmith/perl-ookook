package OokOok::Collection;

=head1 NAME

OokOok::Collection - base class for resource collections

=head1 SYNOPSIS

Declare the resource collection for Foo:

 package OokOok::Collection::Foo;

 use OokOok::Collection;
 use namespace::autoclean;

Use the collection:

 $foo_collection = OokOok::Collection::Foo -> new(c => $c);
 $foo_collection -> GET # returns the JSON structure listing all Foos
 $foo_collection -> link # returns the URL for the collection

=cut

use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;
use namespace::autoclean;

use Carp;

use OokOok::Base::Collection;
use OokOok::Meta::Collection;
use String::CamelCase qw(decamelize);
use Lingua::EN::Inflect qw(PL_N);
use Module::Load ();

Moose::Exporter->setup_import_methods(
  with_meta => [ 'resource_class', 'resource_model' ],
  as_is     => [ ],
  also       => 'Moose',
);

sub init_meta {
  shift;
  my %args = @_;

  Moose->init_meta(%args);

  Moose::Util::MetaRole::apply_metaroles(
     for             => $args{for_class},
     class_metaroles => { 
       class => ['OokOok::Meta::Collection'],
     }
  );

  my $meta = $args{for_class}->meta();

  $meta -> superclasses("OokOok::Base::Collection");

  my $class = $args{for_class};

  $class =~ s{::Collection::}{::Resource::};

  eval { Module::Load::load($class) };
  $meta -> resource_class($class) unless $@;

  $class =~ s{^.*::Resource::}{DB::};

  $meta -> resource_model($class);

  $class =~ s{^.*::}{};
  $class = decamelize($class);
  $class = join("_", split(/\s/, PL_N(join(" ", split(/_/, $class)))));

  #print STDERR "default for resource_name: [$class]\n";
  $meta -> resource_name($class);

  return $meta;
}

sub resource_class {
  my($meta, $class) = @_;

  eval { Module::Load::load($class) };
  croak $@ if $@;
  $meta -> resource_class($class);
}
  
sub resource_model {
  my($meta, $class) = @_;

  $meta -> resource_model($class);
}
  
sub resource_name {
  my($meta, $class) = @_;

  $meta -> resource_name($class);
}

1;

__END__ 
