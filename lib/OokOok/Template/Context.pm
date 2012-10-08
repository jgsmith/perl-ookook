use MooseX::Declare;

# PODNAME: OokOok::Template::Context

# ABSTRACT: Context container for rendering content

class OokOok::Template::Context {
  use MooseX::Types::Moose qw/CodeRef ArrayRef Str HashRef/;

=method new (%options)

The constructor takes the following options:

=for :list
* parent (OokOok::Template::Context)
* document (OokOok::Template::Document)
* namespaces (HashRef)
* vars (HashRef)
* is_mockup (Bool)
* resources (HashRef)

=cut

  has parent => (
    isa => 'Maybe[OokOok::Template::Context]',
    is => 'ro',
    predicate => 'has_parent',
  );

  has document => (
    isa => 'Maybe[OokOok::Template::Document]',
    is => 'ro',
    predicate => 'has_document',
  );

  has namespaces => (
    isa => 'HashRef',
    is => 'ro',
    default => sub { +{} },
  );

  has vars => (
    isa => 'HashRef',
    is => 'ro',
    default => sub { +{ } },
    lazy => 1,
  );

  has is_mockup => (
    isa => 'Bool',
    is => 'rw',
    default => 0,
  );

  has resources => (
    isa => 'HashRef',
    is => 'ro',
    default => sub { +{ } },
    lazy => 1,
  );

  has _namespace_context => (
    isa => 'HashRef',
    is => 'rw',
    default => sub { +{ } },
    lazy => 1,
  );

  has _yield => (
    isa => 'Maybe[CodeRef]',
    is => 'rw',
    predicate => 'has_yield',
  );

=method localize ()

Returns a new OokOok::Template::Context that provides a localized set of
variables and other settings. The context on which this method is called
becomes the parent of the returned context.

=cut

  method localize {
    OokOok::Template::Context -> new( 
      parent => $self,
      document => $self -> document,
      is_mockup => $self -> is_mockup,
    );
  }

=method delocalize ()

Returns the parent of the context if the context has a parent. Otherwise,
it returns itself.

This is useful if you need to climb up the stack of localizations.

=cut

  method delocalize {
    if($self -> has_parent) { return $self -> parent; }
    else                    { return $self;           }
  }

=method get_resource (Str $key)

Returns the resource associated with the given key. If the resource
is not in the current context, then the request is passed to the
context's parent context if it has one.

=cut

  method get_resource (Str $key) {
    if(!exists($self -> resources -> {$key}) && $self -> parent) {
      $self -> parent -> get_resource($key);
    }
    else {
      $self -> resources -> {$key};
    }
  }

=method set_resource (Str $key, Object $value)

Associates the given resource object with the key in the current context.

=cut

  method set_resource (Str $key, Object $value) {
    $self -> resources -> {$key} = $value;
  }

=method set_var (Str $key, Any $val)

Associates the given value with the key in the current context.

=cut

  method set_var ($key, $val) {
    $self -> vars -> {$key} = $val;
  }

=method get_var (Str $key)

=cut

  method get_var (Str $key) {
    if(!exists($self -> vars -> {$key})) {
      if($self -> has_parent) {
        return $self -> parent -> get_var($key);
      }
    }
    my $val = $self -> vars -> {$key};
    if(is_CodeRef($val)) {
      return $val->();
    }
    return $val;
  }

=method has_var (Str $key)

=cut

  method has_var ($key) {
    return 1 if exists($self -> vars -> {$key});

    return 0 unless $self -> parent;

    return $self -> parent -> has_var($key);
  }

=method set_yield (CodeRef $code)

=cut

  method set_yield (CodeRef $code) {
    $self -> _yield($code);
  }

=method yield_nothing ()

=cut

  # this is used to partition off the yield stack
  method yield_nothing { $self -> _yield(sub{ '' }) }

=method yield (Object $ctx?)

=cut

  method yield(Object $ctx?) {
    if($self -> has_yield) {
      return $self -> _yield -> ($ctx || $self);
    }
    elsif($self -> has_parent) {
      if($ctx) {
        return $self -> parent -> yield($ctx);
      }
      else {
        return $self -> parent -> yield;
      }
    }
  }

=method get_namespace (Str $prefix)

=cut

  method get_namespace (Str $prefix) {
    if(!exists($self -> namespaces -> {$prefix})) {
      if($self -> has_parent) {
        return $self -> parent -> get_namespace($prefix);
      }
    }
    return $self -> namespaces -> {$prefix};
  }

=method get_prefix (Str $ns)

=cut

  method get_prefix (Str $ns) {
    for my $p (keys %{$self -> namespaces}) {
      return $p if $self -> namespaces -> {$p} eq $ns;
    }
    return $self -> parent -> get_prefix($ns)
      if $self -> has_parent;
  }

=method process_node (Str|HashRef|ArrayRef $node)

=cut

  method process_node (Str|HashRef|ArrayRef $node) {
    if(is_Str($node)) {
      return $node;
    }
    elsif(is_HashRef($node)) {
      my $local = $node->{local};
      my $ns = $self -> get_namespace($node->{prefix});
      if($ns) {
        my $taglib = $self -> document -> taglibs -> {$ns};
        if($taglib) {
          return $taglib -> process_node($self, $node);
        }
      }
      return ''; # unrecognized tag/namespace
    }
    else { # if(is_ArrayRef($node)) {
      return join '', map {
        $self -> process_node($_)
      } grep { defined } @{$node};
    }
  }

  method add_namespace_context ( Str $ns, Str $local ) {
    $self -> _namespace_context -> {$ns} ||= [];
    push @{$self -> _namespace_context -> {$ns}}, split(/:/, $local);
  }

  method get_namespace_context( Str $ns ) {
    if($self -> has_parent) {
      return $self -> parent -> get_namespace_context($ns), @{$self -> _namespace_context -> {$ns} || []};
    }
    else {
      return @{$self -> _namespace_context -> {$ns} || []};
    }
  }
}
