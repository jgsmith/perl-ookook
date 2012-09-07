use MooseX::Declare;

class OokOok::Declare::Keyword::RESTController
  extends CatalystX::Declare::Keyword::Controller {

  after add_namespace_customizations ($ctx, $package) {
    # we want to load the Collection and Resource for the controller
    my $resource_name = $package;
    $resource_name =~ s{^.*::}{};
    $ctx -> add_preamble_code_parts(
      sprintf 'use OokOok::Resource::%s; use OokOok::Collection::%s;',
              $resource_name, $resource_name
    );
  }

  method default_superclasses { 'OokOok::Base::REST' }
}
