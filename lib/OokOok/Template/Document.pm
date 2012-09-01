use MooseX::Declare;

class OokOok::Template::Document {

  use OokOok::Template::Context;

  has content => (
    is => 'ro',
    required => 1,
    isa => 'ArrayRef',
  );

  has taglibs => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { +{ } },
  );

  has namespaces => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { +{ } },
  );

  method render ($parent_context) {
    OokOok::Template::Context -> new(
      parent => $parent_context,
      namespaces => $self -> namespaces,
      document => $self,
      is_mockup => $parent_context -> is_mockup
    ) -> process_node(
      $self -> content
    );
  }
}
