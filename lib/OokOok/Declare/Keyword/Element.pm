use MooseX::Declare;

# PODNAME: OokOok::Declare::Keyword::Element

# ABSTRACT: Handle tag library element declarations

$OokOok::Declare::SCOPE::UNDER = '';
@OokOok::Declare::SCOPE::UNDER_STACK = ( );

class OokOok::Declare::Keyword::Element 
  with MooseX::Declare::Syntax::KeywordHandling {

  use Moose::Util;
  use Perl6::Junction qw( any );
  use Carp qw( croak );

  use constant STOP_PARSING => '__MXDECLARE_STOP_PARSING__';
  use constant UNDER_STACK  => '@OokOok::Declare::SCOPE::UNDER_STACK';

  use aliased 'CatalystX::Declare::Context::StringParsing';
  use aliased 'MooseX::Method::Signatures::Meta::Method';
  use aliased 'MooseX::MethodAttributes::Role::Meta::Method', 'AttributeRole';
  use aliased 'MooseX::MethodAttributes::Role::Meta::Role',   'AttributeMetaRole';

  method parse (Object $ctx, Str :$modifier?, Int :$skipped_declarator = 0) {
    my %attributes = ( Returns => 'Str' );
    my @populators;

    # parse declarations
    until ( do { $ctx -> skipspace; $ctx -> peek_next_char } eq any qw( ; { } )) {
      $ctx -> skipspace;
      # optional commas
      if( $ctx -> peek_next_char eq ',') {
        my $linestr = $ctx -> get_linestr;
        substr($linestr, $ctx->offset, 1) = '';
        $ctx -> set_linestr($linestr);

        next;
      }

      my $option = (
        $skipped_declarator
        ? $ctx -> strip_name
        : do {
          $ctx -> skip_declarator;
          $skipped_declarator++;
          $ctx -> declarator;
        })
      or croak "Expected option token, not ". substr($ctx->get_linestr, $ctx->offset);

      my $handler = $self -> can("_handle_${option}_option")
        or croak "Unknown element option: $option";

      my $populator = $self -> $handler( $ctx, \%attributes);

      if( $populator and $populator eq STOP_PARSING ) {
        return $ctx -> shadow(sub (&) {
          my ($body) = @_;
          return $body->();
        });
      }

      push @populators, $populator if defined $populator;
    }

    #croak "Need an element specification"
    #  unless exists $attributes{Signature};

    my $name = $attributes{Subname};
    my $orig_sig = $attributes{Signature};
    my @signature;
    push @signature, 'Object $self: Object $ctx';
    if($attributes{Flags}{yielding}) {
      push @signature, 'CodeRef $yield';
    }
    elsif($attributes{Flags}{structured}) {
      push @signature, 'HashRef $children';
    }

    # register the element with the metaclass
    my %el_info = (
      name => substr($attributes{ElementName}, 1, -1),
      impl => substr($attributes{Subname}, 1, -1),
      yields => $attributes{Flags}{yielding},
      structured => $attributes{Flags}{structured},
      returns => $attributes{Returns},
    );

    # for now, we care about attributes like 'Type :$name'
    my @bits = $attributes{Signature} =~ m{\b(\S+?\s*:\$\S+\b\??)}g;
    
    foreach my $bit (@bits) {
      my $opt = 0;
      if($bit =~ s{\?$}{}) {
        $opt = 1;
      }
      $bit =~ m{^(\S+)?\s*:\$(\S+)};
      my($type, $name) = ($1, $2);
      push @signature, "ArrayRef :\$$name".($opt ? '?' : '');
      $el_info{attributes}{""}{$name} = {
        type => $type,
        required => !$opt,
      };
    }
    my $signature = join(", ", @signature);

    my $method;

    $method = Method -> wrap(
      signature => qq{($signature)},
      package_name => $ctx -> get_curstash_name,
      name => $name,
    );

    AttributeRole -> meta -> apply($method);

    for my $p (@populators) {
      $method -> $p;
    }

    my $code = ' sub ';
    $ctx -> inject_code_parts_here($code);
    $ctx -> inc_offset(length $code);

    if($ctx -> peek_next_char eq '{') { # '}'
      $ctx -> inject_if_block( $ctx -> scope_injector_call . $method -> injectable_code );
    }
    else {
      $ctx -> inject_code_parts_here(
        sprintf '{ %s%s }',
          $ctx -> scope_injector_call,
          $method -> injectable_code,
      );
    }

    my $compiled_attrs = sub {
      my $attributes = shift;
      my @attributes;

      return \@attributes;
    };

    return $ctx -> shadow(sub {
      my $class = caller;
      my $attrs = shift;
      my $body = shift;

      my $name = substr($attributes{Subname}, 1, -1);
      $body = $attrs and $attrs = {} if ref $attrs eq 'CODE';

      my $under = join("_", "element", grep { defined } (@OokOok::Declare::SCOPE::UNDER_STACK, $attrs->{Chained}));

      my $el_name = join(":", grep { defined } (@OokOok::Declare::SCOPE::UNDER_STACK, $attrs->{Chained}, $el_info{name}));

      $name = $under . substr($name, 7);

      $method -> name($name);

      my $real_method = $method -> reify(
        actual_body => $body,
        attributes => $compiled_attrs,
        name => $name,
      );

      my $prepare_meta = sub {
        my($meta) = @_;
        $meta -> add_element( $el_name, %el_info, impl => $name );
        $meta -> add_method( $name, $real_method );
        #$meta -> register_method_attributes($meta -> name -> can( $real_method -> name ), $compiled_attrs );
      };

      if( $ctx -> stack -> [-1] and $ctx -> stack -> [-1] -> is_parameterized) {
        my $real_meta = MooseX::Role::Parameterized->current_metaclass;
        $real_meta -> meta -> make_mutable
          if $real_meta -> meta -> is_immutable;
        ensure_all_roles($real_meta -> meta, AttributeMetaRole)
          if $real_meta -> isa('Moose::Meta::Role');

        $real_meta -> $prepare_meta;
      }
      else {
        $class -> meta -> $prepare_meta;
      }
    });
  }

  method _handle_as_option (Object $ctx, HashRef $attrs) {
    my $el_name = $self -> _strip_string( $ctx, interpolate => 0 );
    $ctx -> skipspace;

    $attrs->{ElementName} = $el_name;

    return sub { }
  }

  method _handle_element_option (Object $ctx, HashRef $attrs) {
    my $name = $self -> _strip_string ( $ctx, interpolate => 1 )
      or croak "Anonymous elements are not supported";
 
    $ctx -> skipspace;
    my $populator;

    my $proto = $ctx -> strip_proto || '';

    $attrs -> {ElementName} ||= $name;

    $name = "'element_" . substr($name, 1);
    $attrs -> {Subname} = $name;
    $attrs -> {Signature} = $proto;
    return unless $populator;
    return $populator;
  }

  method _handle_is_option (Object $ctx, HashRef $attrs) {
    my $flag = $self -> _strip_string( $ctx, interpolate => 0 )
      or croak "Flag expected after keyword 'is'";
 
    $ctx -> skipspace;

    $attrs -> {Flags} -> {$flag} = 1;
    return;
  }

  method _handle_as_option (Object $ctx, HashRef $attrs) {
    my $el_name = $self -> _strip_string( $ctx, interpolate => 1 )
      or croak "Element name expected after keyword 'as'";

    $ctx -> skipspace;

    $attrs -> {ElementName} = $el_name;

    return;
  }

  method _handle_returns_option (Object $ctx, HashRef $attrs) {
    my $ret = $self -> _strip_string( $ctx, interpolate => 0 )
      or croak "Str or HTML expected after keyword 'returns'";

    if($ret ne 'Str' && $ret ne 'HTML') {
      croak "Str or HTML expected after keyword 'returns'";
    }

    $attrs -> {Returns} = $ret;

    return;
  }

  method _handle_under_option (Object $ctx, HashRef $attrs) {
    my $target = $self -> _strip_actionpath($ctx, interpolate => 1);
    $ctx -> skipspace;

    if($ctx->peek_next_char eq '{' and $self -> identifier eq 'under') {
      $ctx -> inject_if_block(
        $ctx -> scope_injector_call(sprintf 'pop %s;',UNDER_STACK) .
        sprintf ';push %s, %s;',
          UNDER_STACK,
          $target,
      );
      return STOP_PARSING;
    }

    $attrs->{Chained} = $target;

    return sub {
      my $method = shift;
    };
  }

  method _strip_string (Object $ctx, :$interpolate?) {
    $ctx -> skipspace;

    my $linestr = $ctx -> get_linestr;
    my $rest = substr($linestr, $ctx->offset);
    my $interp = sub { $interpolate ? "'$_[0]'" : $_[0] };

    if( $rest =~ /^ ( [_a-z] [_a-z0-9]* ) \b/ix) {
      substr($linestr, $ctx -> offset, length($1)) = '';
      $ctx -> set_linestr($linestr);
      return $interp->($1);
    }

    elsif ( $rest =~ /^ ' ( (?:[.:;,_a-z0-9]|\/)* ) ' /ix) {
      substr($linestr, $ctx->offset, length($1) + 2) = '';
      $ctx -> set_linestr($linestr);
      return $interp->($1);
    }

    elsif ($interpolate and my $str = $ctx->get_string) {
      return $str;
    }
    else {
      croak "Invalid syntax for element name: $rest";
    }
  }

  method _strip_actionpath (Object $ctx, :$interpolate?) {

    $ctx->skipspace;
    my $linestr = $ctx->get_linestr;
    my $rest    = substr($linestr, $ctx->offset);
    my $interp  = sub { $interpolate ? "'$_[0]'" : $_[0] };

    # find simple barewords
    if ($rest =~ /^ ( [_a-z] [_a-z0-9]* ) \b/ix) {
      substr($linestr, $ctx->offset, length($1)) = '';
      $ctx->set_linestr($linestr);
      return $interp->($1);
    }

    # allow single quoted more complex barewords
    elsif ($rest =~ /^ ' ( (?:[.:;,_a-z0-9]|\/)* ) ' /ix) {
      substr($linestr, $ctx->offset, length($1) + 2) = '';
      $ctx->set_linestr($linestr);
      return $interp->($1);
    }

    # double quoted strings and variables
    elsif ($interpolate and my $str = $ctx->get_string) {
      return $str;
    }

    # not suitable as action path
    else {
      croak "Invalid syntax for action path: $rest";
    }
  }

 
  with 'MooseX::Declare::Syntax::KeywordHandling';

  around context_traits { $self->$orig, StringParsing }
}
