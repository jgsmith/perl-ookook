package OokOok::Shell::CommandSet;
use Moose::Exporter;
use OokOok::Shell::CommandSet::Base;
use Data::Dumper;

Moose::Exporter -> setup_import_methods(
  with_meta => [
    qw(
      prefix
      command
    )
  ],
  also => [ 'Moose' ],
);

sub init_meta {
  shift;
  my %args = @_;

  my %nargs;
  $nargs{for_class} = $args{for_class}
      or Moose->throw_error("Cannot call init_meta without specifying a for_class");
  $nargs{base_class} = $args{base_class} || 'OokOok::Shell::CommandSet::Base';
  if( exists $args{meta_name} ) {
    $nargs{meta_name} = $args{meta_name};
  }

  Moose -> init_meta( %nargs );
}

sub prefix {
  my($meta, $prefix) = @_;

  #print STDERR "Setting prefix $prefix\n";

  $meta -> {pacakge} -> instance -> prefix($prefix);
}

sub command {
  my($meta, $name, $code) = @_;

  #print STDERR "Adding command $name\n";

  $meta -> {package} -> instance -> commands -> {$name} = $code;
}

1;
