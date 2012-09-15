use MooseX::Declare;

# PODNAME: OokOok::Declare::Base::TagLibrary

class OokOok::Declare::Base::TagLibrary {

  use MooseX::Types::Moose qw( ArrayRef );

  has c => ( is => 'rw', isa => 'Maybe[Object]',);

  has date => ( is => 'rw',);

  method process_node ($ctx, $node) {
    # we want to pull out attributes and such based on needs of tag
    my $name = $node -> {local};
    my $einfo = $self -> meta -> element( $name );
    return if !$einfo; # TODO: perhaps throw an error if not a defined element

    return if !$einfo -> {impl}; # Nothing to do, so don't do anything

    my $context = $ctx -> localize;
    my $xmlns;
    my $attributes = {};
    for my $ns (keys %{$einfo->{attributes}}) {
      $xmlns = $ns;
      if($ns eq '') {
        $xmlns = $self -> meta -> taglib_namespace;
      }
      $xmlns = $context -> get_prefix($xmlns);
      for my $a (keys %{$einfo->{attributes}->{$ns}||{}}) {
        my $value = $node -> {attrs} -> {$xmlns} -> {$a};
        if($einfo->{attributes}->{$ns}->{$a}->{type} eq 'Str') {
          if(defined $value) {
            $attributes->{$a} = $value;
          }
        }
        elsif($einfo->{attributes}->{$ns}->{$a}->{type} eq 'Bool') {
          if(defined($value)) {
            $attributes->{$a} = [ map {
              m{^\s*(yes|true|on|1)\s*$} ? 1 : 0
            } @{$value} ];
          }
        }
        if($einfo->{attributes}->{$ns}->{$a} -> {required}) {
          die "$a undefined by required" unless defined $attributes->{$a};
        }
      }
    }

    my $yield;
    if($einfo -> {yields} && @{$node -> {children}||[]}) {
      $yield = sub { 
        $context -> process_node( $node -> {children} || [''] );
      };
    }

    my $impl = $einfo -> {impl};
    if($einfo -> {yields}) {
      $self -> $impl($context, $yield, %$attributes);
    }
    else {
      $self -> $impl($context, %$attributes);
    }
  }
}
