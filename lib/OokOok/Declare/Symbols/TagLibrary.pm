package OokOok::Declare::Symbols::TagLibrary;

# ABSTRACT: Declarative elements for defining tag libraries

use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;

use OokOok::Declare::Base::TagLibrary;
use OokOok::Declare::Meta::TagLibrary;

use namespace::autoclean;

Moose::Exporter -> setup_import_methods(
  with_meta => [ 'ns', 'documentation' ],
  as_is => [ ],
  #also => 'Moose',
);

sub init_meta {
  shift;
  my %args = @_;

  Moose -> init_meta(%args);

  Moose::Util::MetaRole::apply_metaroles(
    for             => $args{for_class},
    class_metaroles => {
      class => ['OokOok::Declare::Meta::TagLibrary'],
    },
  );

  my $meta = $args{for_class} -> meta;

  #$meta -> superclasses("OokOok::Declare::Base::TagLibrary");

  return $meta;
}

sub ns { 
  my($meta, $ns) = @_;

  $meta -> taglib_namespace($ns);
}

sub documentation {
  my($meta, $d) = @_;

  $meta -> set_documentation($d);
}

#sub element {
#  my($meta, $name, %options) = @_;
#
#  $meta -> add_element($name, %options);
#}

1;
