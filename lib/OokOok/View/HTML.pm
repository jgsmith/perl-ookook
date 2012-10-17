use CatalystX::Declare;

# PODNAME: OokOok::View::HTML

# ABSTRACT: View Using Template Toolkit 2

view OokOok::View::HTML is mutable
  extends Catalyst::View::TT {

  __PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt2',
    render_die => 1,
    ABSOLUTE => 1,
    RELATIVE => 1
  );

  #
  # This is for the RESTful pieces of the app
  #
  before process ($ctx, @stuff) {
    my $stash_key = shift @stuff;
    if($stash_key) {
      $ctx -> stash -> {data} = $ctx -> stash -> {$stash_key};
    }
  }

}

=head1 DESCRIPTION

TT View for OokOok.

=head1 SEE ALSO

L<OokOok>

=cut
