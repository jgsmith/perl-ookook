use utf8;
package OokOok::Schema::Result::Project;

=head1 NAME

OokOok::Schema::Result::Project

=cut

use OokOok::EditionedResult;
use namespace::autoclean;

has_editions 'OokOok::Schema::Result::Edition';

owns_many pages    => 'OokOok::Schema::Result::Page';
owns_many snippets => 'OokOok::Schema::Result::Snippet';

after insert => sub {
  my($self) = @_;

  my $ce = $self -> current_edition;
  my $home_page = $self -> create_related('pages', { });

  $home_page -> current_version -> update({
    title => 'Home',
    description => 'Top-level page for the project site.',
    slug => '',
  });
  $ce -> update({
    page => $home_page
  });
  $ce -> update_or_insert;

  print STDERR "CE page id: ", $ce -> page_id, "\n";
  print STDERR "Home page id: ", $home_page -> id, "\n";
  while($ce -> is_changed) {
    print STDERR "CE marked as changed: ", $ce -> is_changed, "\n";
    $ce -> update_or_insert;
  }
  
  print STDERR "CE page id: ", $ce -> page_id, "\n";
  print STDERR "CE marked as changed: ", $ce -> is_changed, "\n";
  

  # now add libraries that should be included automatically
  my @libs = $self -> result_source->schema-> resultset('Library') -> search({
    new_project_prefix => { '!=' => undef }
  });
  for my $lib (@libs) {
    # we should filter out any libraries without a published edition
    #my $pl = $self -> create_related('library_projects', {
    #  library_id => $lib -> id
    #});
    #$pl -> insert_or_update;
    #$pl -> current_version -> update({
    #  prefix => $lib -> new_project_prefix
    #});
  }
    
  $self;
};

sub page_count { $_[0] -> pages -> count + 0 }

sub page {
  my($self, $uuid) = @_;

  $self -> pages -> find({ uuid => $uuid });
}

=head2 edition_for_date

Given a date, find the project instance that is appropriate. If no
date is given, then find the most recent project instance.

=cut

=head2 edition_path

Given a date, return a list of project instances to search through for
the appropriate object.

=cut

sub edition_path {
  my($self, $date) = @_;

  my $q = $self -> editions;

  return $self -> _apply_date_constraint($q, "", $date) -> all;
}

1;
