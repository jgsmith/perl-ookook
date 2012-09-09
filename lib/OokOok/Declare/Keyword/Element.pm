use MooseX::Declare;

# PODNAME: OokOok::Declare::Keyword::Element

# ABSTRACT: Handle tag library element declarations

class OokOok::Declare::Keyword::Element 
  with MooseX::Declare::Syntax::KeywordHandling {

  use Moose::Util;

  method register_method_declaration($meta, $name, $method) {
    $meta -> add_method( $name, $method -> body );
  }

  method parse ($ctx) {
    my %args = (
      context => $ctx -> _dd_context,
      initialized_context => 1,
      custom_method_application => sub {
        my($meta, $name, $method) = @_;
        my $nom = $name;
        $nom =~ s{-}{_}g;
        $self -> register_method_declaration($meta, "element_" . $nom, $method);
      },
    );

    $args{prototype_injections} = {
      declarator => 'element',
      injections => [ 'Object $ctx' ]
    };

    my $mxms = MooseX::Method::Signatures -> new(%args);

    $mxms -> parser;
  }
}
