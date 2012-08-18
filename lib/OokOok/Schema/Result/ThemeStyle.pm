use utf8;
package OokOok::Schema::Result::ThemeStyle;

=head1 NAME

OokOok::Schema::Result::ThemeStyle

=cut

use OokOok::VersionedResult;
use namespace::autoclean;

__PACKAGE__ -> has_many( theme_layout_versions => 'OokOok::Schema::Result::ThemeLayoutVersion', 'theme_style_id');

1;
