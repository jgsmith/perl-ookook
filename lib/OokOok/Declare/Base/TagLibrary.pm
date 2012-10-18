use MooseX::Declare;
use feature 'switch';

# PODNAME: OokOok::Declare::Base::TagLibrary

# ABSTRACT: Base class for tag libraries

class OokOok::Declare::Base::TagLibrary {

  use MooseX::Types::Moose qw( ArrayRef HashRef );

  use feature 'switch';

  has c => ( is => 'rw', isa => 'Maybe[Object]',);

  has date => ( is => 'rw',);

  method process_node ($ctx, $node) {
    # we want to pull out attributes and such based on needs of tag
    my $name = $node -> {local};
    my @context = $ctx -> get_namespace_context($node -> {prefix});
    my $elements = $self -> meta -> elements;
    push @context, $name;
    my $einfo;
    while(!$einfo && @context) {
      $einfo = $elements -> {join(":", @context)};
      shift @context;
    }

    # if we don't find anything, then we'll push the tag name onto the
    # stack and dive in
    if(!$einfo || !$einfo -> {impl}) {
      if(@{$node->{children}||[]}) {
        $ctx = $ctx -> localize;
        $ctx -> add_namespace_context($node -> {prefix}, $name);
        return $ctx -> process_node( $node -> {children} );
      }
      else {
        # TODO: perhaps throw an error if not a defined element
        return '';
      }
    }
      
    my $context = $ctx -> localize;
    $context -> add_namespace_context( $node->{prefix}, $name );
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
        if(defined $value) {
          given( $einfo->{attributes}->{$ns}->{$a}->{type} ) {
            when('Str') {
              $attributes->{$a} = $value;
            }
            when('Bool') {
              $attributes->{$a} = [ map {
                m{^\s*(yes|true|on|1)\s*$} ? 1 : 0
              } @{$value} ];
            }
            when('Int') {
              $attributes->{$a} = [ map { 0+$_ } @{$value} ];
            }
          }
        }
        if($einfo->{attributes}->{$ns}->{$a} -> {required}) {
          die "$a undefined but required" unless defined $attributes->{$a};
        }
      }
    }

    my($yield, $structured) = (sub { '' }, +{ });

    if(@{$node -> {children}||[]}) {
      if($einfo -> {yields}) {
        $yield = sub { 
          my $ctx = @_ ? $_[0] : $context;
          $ctx = $ctx -> localize;
          #$ctx -> add_namespace_context($node -> {prefix}, $name);
          $ctx -> process_node( $node -> {children} || [''] );
        };
      }
      elsif($einfo -> {structured}) {
        for my $child (@{$node -> {children} || []}) {
          next unless is_HashRef($child);
          $structured -> {$child -> {local}} ||= [];
          push @{$structured->{$child->{local}}}, sub {
            my $ctx = @_ ? $_[0] : $context;
            $ctx = $ctx -> localize;
            #$ctx -> add_namespace_context($child -> {prefix}, $child->{local});
            $ctx -> process_node( $child );
          };
        }
      }
    }

    my $impl = $einfo -> {impl};
    my $value;
    if($einfo -> {yields}) {
      $value = $self -> $impl($context, $yield, %$attributes);
    }
    elsif($einfo -> {structured}) {
      $value = $self -> $impl($context, $structured, %$attributes);
    }
    else {
      $value = $self -> $impl($context, %$attributes);
    }

    # if not specified, or HTML, we do nothing with the value
    given($einfo->{returns}) {
      when ('Str') {
        for ($value) {
          s/&/&amp;/g;
          s/</&lt;/g;
          s/>/&gt;/g;
          s/"/&quot;/g;
          s/'/&#39;/g;
        }
      }
    }

    return $value;
  }
}
