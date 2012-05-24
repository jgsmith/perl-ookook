package OokOok::View::HTML;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt2',
    render_die => 1,
    TIMER => 1,
    WRAPPER => 'wrapper.tt2',
);

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

1;
