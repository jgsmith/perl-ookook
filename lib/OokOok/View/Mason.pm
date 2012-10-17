use CatalystX::Declare;

# PODNAME: OokOok::View::Mason

# ABSTRACT: View Using Mason2

view OokOok::View::Mason is mutable
  extends Catalyst::View::Mason2 {

  __PACKAGE__ -> config(
    plugins => [
      'HTMLFilters'
    ]
  );
}
