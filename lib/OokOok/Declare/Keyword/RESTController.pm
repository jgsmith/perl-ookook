use MooseX::Declare;

# PODNAME: OokOok::Declare::Keyword::RESTController

# ABSTRACT: Implementation for rest_controller keyword

class OokOok::Declare::Keyword::RESTController
  extends CatalystX::Declare::Keyword::Controller {

  use String::CamelCase qw(decamelize);

  after add_namespace_customizations ($ctx, $package) {
    # we want to load the Collection and Resource for the controller
    my $resource_name = $package;
    $resource_name =~ s{^.*::}{};
    $ctx -> add_preamble_code_parts(
      sprintf 'use OokOok::Resource::%s; use OokOok::Collection::%s;',
              $resource_name, $resource_name
    );
    #$ctx -> add_preamble_code_parts(
    #  sprintf '%s -> config( map => { }, default => "text/html" );', 
    #          $package
    #);

    my $base = $package;
    $base =~ s{^.*::}{};
    $base = decamelize($base);
    $base =~ s{_}{-};
    $base = lc $base;
    $ctx -> add_preamble_code_parts(
      qq{action base as "$base" under "/";}
    );
  }

  method default_superclasses { 'OokOok::Declare::Base::REST' }
}
