package OokOok::Template::Context;

use Moose;

# ABSTRACT: Context container for rendering content

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
    #isa => 'Maybe[OokOok::Template::Context]',
    is => 'ro',
    predicate => 'has_parent',
  );

  has document => (
    #isa => 'Maybe[OokOok::Template::Document]',
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
    #lazy => 1,
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
    #lazy => 1,
  );

  has _namespace_context => (
    isa => 'HashRef',
    is => 'rw',
    default => sub { +{ } },
    #lazy => 1,
  );

  has _yield => (
    isa => 'Maybe[CodeRef]',
    is => 'rw',
    predicate => 'has_yield',
  );

=method project_url (Str $path)

Returns the proper URL given the project and dated or development version
of the resource being viewed.

=cut

sub project_url {
  my($self, $path) = @_;
  my $project = $self -> get_resource('project');
  return '' unless $project;

  my $url = '/v/' . $project -> id . '/' . $path;
  $url =~ s{/+}{/}g;
  return $project -> c -> uri_for($url);
}

=method localize ()

Returns a new OokOok::Template::Context that provides a localized set of
variables and other settings. The context on which this method is called
becomes the parent of the returned context.

=cut

sub localize {
  my($self) = @_;

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

sub delocalize {
  my($self) = @_;

  if($self -> has_parent) { return $self -> parent; }
  else                    { return $self;           }
}

=method get_resource (Str $key)

Returns the resource associated with the given key. If the resource
is not in the current context, then the request is passed to the
context's parent context if it has one.

=cut

sub get_resource {
  my($self, $key) = @_;

  if(!exists($self -> resources -> {$key}) && $self -> parent) {
    $self -> resources -> {$key} = $self -> parent -> get_resource($key);
  }
  else {
    $self -> resources -> {$key};
  }
}

=method set_resource (Str $key, Object $value)

Associates the given resource object with the key in the current context.

=cut

sub set_resource {
  my($self, $key, $value) = @_;

  $self -> resources -> {$key} = $value;
}

=method set_var (Str $key, Any $val)

Associates the given value with the key in the current context.

=cut

sub set_var {
  my($self, $key, $val) = @_;
  $self -> vars -> {$key} = $val;
}

=method get_var (Str $key)

=cut

sub get_var {
  my($self, $key) = @_;
  if(!exists($self -> vars -> {$key})) {
    if($self -> has_parent) {
      return $self -> vars -> {$key} = $self -> parent -> get_var($key);
    }
  }

  my $val = $self -> vars -> {$key};
  return $val->() if is_CodeRef($val);
  return $val;
}

=method has_var (Str $key)

=cut

sub has_var {
  my($self, $key) = @_;
  return 1 if exists($self -> vars -> {$key});

  return 0 unless $self -> parent;

  return $self -> parent -> has_var($key);
}

=method set_yield (CodeRef $code)

=cut

sub set_yield { $_[0] -> _yield($_[1]); }

=method yield_nothing ()

=cut

  # this is used to partition off the yield stack
sub yield_nothing { $_[0] -> _yield(sub{ '' }) }

=method yield (Object $ctx?)

=cut

sub yield {
  my($self, $ctx) = @_;

  return $self -> _yield -> ($ctx || $self) if $self -> has_yield;

  return $self -> parent -> yield($ctx) if $self -> has_parent;
}

=method get_namespace (Str $prefix)

=cut

sub get_namespace {
  my($self, $prefix) = @_;
  if(!exists($self -> namespaces -> {$prefix})) {
    if($self -> has_parent) {
      return $self -> namespaces -> {$prefix} = $self -> parent -> get_namespace($prefix);
    }
  }
  return $self -> namespaces -> {$prefix};
}

=method get_prefix (Str $ns)

=cut

sub get_prefix {
  my($self, $ns) = @_;
  for my $p (keys %{$self -> namespaces}) {
    return $p if $self -> namespaces -> {$p} eq $ns;
  }
  return $self -> parent -> get_prefix($ns) if $self -> has_parent;
}

=method process_node (Str|HashRef|ArrayRef $node)

=cut

sub process_node {
  my($self, $node) = @_;
  return '' unless defined $node;
  return $node unless ref $node;

  if(is_HashRef($node)) {
    my $local = $node->{local};
    my $ns = $self -> get_namespace($node->{prefix});
    return '' unless $ns;

    my $taglib = $self -> document -> taglibs -> {$ns};
    return $taglib -> process_node($self, $node) if $taglib;
  }
  else { # if(is_ArrayRef($node)) {
    return join '', map {
      $self -> process_node($_)
    } grep { defined } @{$node};
  }
}

sub add_namespace_context {
  my( $self, $ns, $local ) = @_;
  $self -> _namespace_context -> {$ns} ||= [];
  push @{$self -> _namespace_context -> {$ns}}, split(/:/, $local);
}

sub get_namespace_context {
  my($self, $ns) = @_;
  if($self -> has_parent) {
    return $self -> parent -> get_namespace_context($ns), @{$self -> _namespace_context -> {$ns} || []};
  }
  else {
    return @{$self -> _namespace_context -> {$ns} || []};
  }
}

1;
