use CatalystX::Declare;

view OokOok::View::Mason is mutable
  extends Catalyst::View::Mason2 {

  $CLASS -> config(
    plugins => [
      'HTMLFilters'
    ]
  );
}
