package OokOok::Template::TagLibrary;

use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;

use OokOok::Base::TagLibrary;

use namespace::autoclean;

Moose::Exporter -> setup_import_methods(
  with_meta => [ 'element' ],
  as_is => [ ],
  also => 'Moose',
);

sub init_meta {
  shift;
  my %args = @_;

  Moose -> init_meta(%args);

  Moose::Util::MetaRole::apply_metaroles(
    for             => $args{for_class},
    class_metaroles => {
      class => ['OokOok::Meta::TagLibrary'],
    },
  );

  my $meta = $args{for_class} -> meta;

  $meta -> superclasses("OokOok::Base::TagLibrary");

  return $meta;
}

#sub namespace {
#  my($meta, $ns) = @_;
#
#  $meta -> namespace($ns);
#}

sub element {
  my($meta, $name, %options) = @_;

  $meta -> add_element($name, %options);
}

1;
