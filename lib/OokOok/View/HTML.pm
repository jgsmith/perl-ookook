use CatalystX::Declare;

view OokOok::View::HTML is mutable
  extends Catalyst::View::TT {

  $CLASS->config(
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

=head1 NAME

OokOok::View::HTML - TT View for OokOok

=head1 DESCRIPTION

TT View for OokOok.

=head1 SEE ALSO

L<OokOok>

=head1 AUTHOR

James Smith,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
