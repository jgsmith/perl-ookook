use utf8;
package OokOok::Schema::Result::Page;

=head1 NAME

OokOok::Schema::Result::Page

=cut

use OokOok::VersionedResult;
use namespace::autoclean;

__PACKAGE__ -> has_many( "children" => "OokOok::Schema::Result::PageVersion", "parent_page_id", {
  cascade_copy => 0,
  cascade_delete => 0,
} );

after insert => sub {
  my($self) = @_;

  # make sure we have a 'body' page part
  if(0 == $self -> current_version -> page_parts -> count) {
    my $body = $self -> current_version -> create_related('page_parts', {
      name => 'body',
      content => '',
    });
    $body -> insert_or_update;
  }
};

1;
