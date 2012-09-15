use MooseX::Declare;

# PODNAME: OokOok::Declare::Keyword::AdminController

# ABSTRACT: Provides the admin_controller keyword

class OokOok::Declare::Keyword::AdminController
  extends CatalystX::Declare::Keyword::Controller {

  after add_namespace_customizations ($ctx, $package) {
    # we want to load the Collection and Resource for the controller
    if($package =~ m{::Admin::}) {
      my $resource_name = $package;
      $resource_name =~ s{^.*::}{};
      $ctx -> add_preamble_code_parts(
        sprintf 'use OokOok::Resource::%s; use OokOok::Collection::%s;',
                $resource_name, $resource_name
      );
    }
  }

  method default_superclasses { 'OokOok::Declare::Base::Admin' }
}
