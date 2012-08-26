use utf8;
package OokOok::Schema::Result::Typeface;

=head1 NAME

OokOok::Schema::Result::Typeface

=cut

use OokOok::EditionedResult;
use namespace::autoclean;

has_editions;

owns_many typeface_fonts => 'OokOok::Schema::Result::TypefaceFont';

1;
