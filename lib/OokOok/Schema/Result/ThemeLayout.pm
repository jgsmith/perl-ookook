use utf8;
package OokOok::Schema::Result::ThemeLayout;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::ThemeLayout

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<theme_layout>

=cut

__PACKAGE__->table("theme_layout");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 theme_id

  data_type: 'integer'
  is_nullable: 0

=head2 uuid

  data_type: 'char'
  is_nullable: 0
  size: 20

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "theme_id",
  { data_type => "integer", is_nullable => 0 },
  "uuid",
  { data_type => "char", is_nullable => 0, size => 20 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-06-23 12:03:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aQbDAPCJJWccxy++/dc+BA

with 'OokOok::Role::Schema::Result::HasVersions';

__PACKAGE__ -> belongs_to( theme => 'OokOok::Schema::Result::Theme', 'theme_id' );

sub owner { $_[0] -> theme }

__PACKAGE__ -> has_many( versions => 'OokOok::Schema::Result::ThemeLayoutVersion', 'theme_layout_id');

=head1 Example Layout

Layouts consist of horizontal and vertical boxes. These boxes can contain
other boxes. A box may reference a snippet or a page part.

Each box may be styled.

Layouts are stored as JSON objects.

Box: {
  type => 'Box' | 'Content' | 'Snippet' | 'PagePart',
  content => [ boxes... ], (for Box type)
  width => (1..12)
  heigth => (...)
  class => ...
  content => 'Content', (for Content type)
  content => 'snippet name', (for Snippet type)
  content => 'page part name', (for PagePart type)
}

  

=cut

use feature "switch";
use XML::LibXML;

sub _render_html5 {
  my($self, $stash, $dom, $html5) = @_;

  $stash -> {parser} -> parse_balanced_chunk("<div>" . $html5 . "</div>") -> firstChild;
}

sub _render_content {
  my($self, $stash, $dom, $content) = @_;
  # we expect HTML5 content for now

  $self -> _render_html5($stash, $dom, $content);
}

sub _render_snippet {
  my($self, $stash, $dom, $content) = @_;

  # we need to find the snippet and render it
  my $nom = $content -> getAttribute( 'name' );
  my $snippet = $stash -> {page} -> edition -> snippet($nom);
  my $ret;
  if($snippet) {
    $ret = $self -> _render_html5($stash, $dom, $snippet -> content);
  }
  else {
    $ret = $self -> _render_html5($stash, $dom, "");
  }
  $ret -> setAttribute(class => "snippet snippet-" . $nom);
  $ret;
}

sub _render_page_part {
  my($self, $stash, $dom, $content) = @_;

  # if page doesn't have it, we look up the path until we find a page that does
  my @page_path = @{$stash -> {path} || []};
  my($part, $p, $ret);
  my $nom = $content -> getAttribute( 'name' );
  
  while(!$part && @page_path) {
    $p = pop @page_path while @page_path && !$p;
    print STDERR "page: $p\n";
    if($p) {
      $part = $p -> page_parts -> find({ name => $nom });
    }
  }

  if($part) {
    $ret = $self -> _render_html5($stash, $dom, $part -> content);
  }
  else {
    $ret = $self -> _render_html5($stash, $dom, "");
  }
  # TODO: make sure $nom doesn't have spaces (replace them with '-')
  $ret -> setAttribute(class => "page-part page-part-" . $nom);
  $ret;
}

sub _render_box {
  my($self, $stash, $dom, $box) = @_;

  my $container = $dom -> createElement( "div" );
  my @classes;
  my $width = $box -> getAttribute( 'width' );
  if(defined($width) && $width =~ /^(\d+)$/ && 1 <= $1 && $1 <= 12) {
    push @classes, "span$1";
  }
  my $class = $box -> getAttribute( 'class' );
  if(defined($class) && $class =~ /^[-_a-zA-Z0-9]+$/) {
    push @classes, $class;
  }
  if(@classes) {
    $container -> setAttribute(class => join(" ", @classes));
  }
  
  for my $b ($box -> childNodes()) {
    given($b -> nodeName) {
      when('div') {
        $container -> appendChild($self -> _render_box($stash, $dom, $b));
      }
      #when('Content') {
        #$container -> appendChild($self -> _render_content($stash, $dom, $b));
      #}
      when('snippet') {
        $container -> appendChild($self -> _render_snippet($stash, $dom, $b));
      }
      when('page-part') {
        $container -> appendChild($self -> _render_page_part($stash, $dom, $b));
      }
      when('row') {
        $container -> appendChild($self -> _render_row($stash, $dom, $b));
      }
    }
  }

  return $container;
}

sub _render_row {
  my($self, $stash, $dom, $row) = @_;

  my $container = $dom -> createElement( "div" );
  $container -> setAttribute(class => "row");

  for my $b ($row -> childNodes()) {
    given($b -> nodeName) {
      when('div') {
        $container -> appendChild($self -> _render_box($stash, $dom, $b));
      }
      #when('Content') {
        #$container -> appendChild($self -> _render_content($stash, $dom, $b));
      #}
      when('snippet') {
        $container -> appendChild($self -> _render_snippet($stash, $dom, $b));
      }
      when('page-part') {
        $container -> appendChild($self -> _render_page_part($stash, $dom, $b));
      }
      when('row') {
        $container -> appendChild($self -> _render_row($stash, $dom, $b));
      }
    }
  }

  return $container;
}
  

sub render {
  my($self, $stash, $config, $page) = @_;

  # now we want to render $self -> layout and bring in page content
  # as well as snippets along the way
  $stash -> {page} = $page;
  $stash -> {layout_config} = $config;
  $stash -> {parser} = XML::LibXML->new;

  my $dom = XML::LibXML::Document->new();

  my $layout = eval { XML::LibXML -> load_xml( string => "<layout>" . $self -> layout . "</layout>" ) };

  if($@) {
    return "Unable to parse layout: $@";
  }

  $layout = $layout -> documentElement();

  my $doc = $self -> _render_box($stash, $dom, $layout);
  $doc -> setAttribute(class => "layout-" . $self -> uuid);

  $dom -> setDocumentElement($doc);

  # doesn't have the header stuff in it - we'll want to pass this to
  # the view tt2 template and let it wrap everything in the html5 header stuff
  return $dom -> toStringHTML();
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
