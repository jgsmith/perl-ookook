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

=head2 theme_edition_id

  data_type: 'integer'
  is_nullable: 0

=head2 uuid

  data_type: 'char'
  is_nullable: 0
  size: 20

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 layout

  data_type: 'text'
  default_value: '{}'
  is_nullable: 0

=head2 configuration

  data_type: 'text'
  default_value: '{}'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "theme_edition_id",
  { data_type => "integer", is_nullable => 0 },
  "uuid",
  { data_type => "char", is_nullable => 0, size => 20 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "layout",
  { data_type => "text", default_value => "{}", is_nullable => 0 },
  "configuration",
  { data_type => "text", default_value => "{}", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-05-31 10:35:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3BfRaU4GoRnjp5J3r2ffpw

with 'OokOok::Role::Schema::Result::HasVersions';

use JSON ();

__PACKAGE__ -> belongs_to( "edition" => "OokOok::Schema::Result::ThemeEdition", "theme_edition_id" );

__PACKAGE__->inflate_column('layout', {
  inflate => sub { JSON::decode_json shift },
  deflate => sub { JSON::encode_json shift },
});

__PACKAGE__->inflate_column('configuration', {
  inflate => sub { JSON::decode_json shift },
  deflate => sub { JSON::encode_json shift },
});


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
  my($self, $c, $dom, $html5) = @_;

  $c -> stash -> {parser} -> parse_balanced_chunk("<div>" . $html5 . "</div>");
}

sub _render_content {
  my($self, $c, $dom, $content) = @_;
  # we expect HTML5 content for now

  $self -> _render_html5($c, $dom, $content->{content});
}

sub _render_snippet {
  my($self, $c, $dom, $content) = @_;

  # we need to find the snippet and render it
  my $snippet = $c -> stash -> {page} -> edition -> snippet($content->{content});
  my $ret;
  if($snippet) {
    $ret = $self -> _render_html5($snippet -> content);
  }
  else {
    $ret = $self -> _render_html5("");
  }
  $ret -> setAttribute(class => "snippet-" . $content->{content});
  $ret;
}

sub _render_page_part {
  my($self, $c, $dom, $content) = @_;

  # if page doesn't have it, we look up the path until we find a page that does
  my @page_path = [$c -> stash -> {path}];
  my($part, $p, $ret);
  while(!$part && @page_path) {
    $p = pop @page_path while @page_path && !$p;
    if($p) {
      $part = $p -> page_parts -> find({ name => $content -> content });
    }
  }

  if($part) {
    $ret = $self -> _render_html5($part -> content);
  }
  else {
    $ret = $self -> _render_html5("");
  }
  $ret -> setAttribute(class => "part-" . $content->{content});
  $ret;
}

sub _render_box {
  my($self, $c, $dom, $box) = @_;

  my $container = $dom -> createElement( "div" );
  my @classes;
  if($box->{width} =~ /^(\d+)$/ && 1 <= $1 && $1 <= 12) {
    push @classes, "span$1";
  }
  if(defined($box -> {class}) && $box->{class} =~ /^[-_a-zA-Z0-9]+$/) {
    push @classes, $box->{class};
  }
  if(@classes) {
    $container -> setAttribute(class => join(" ", @classes));
  }
  
  for my $b (@{$box -> {content} || []}) {
    given($b -> {type}) {
      when('Box') {
        $container -> appendChild($self -> _render_box($c, $dom, $b));
      }
      when('Content') {
        $container -> appendChild($self -> _render_content($c, $dom, $b));
      }
      when('Snippet') {
        $container -> appendChild($self -> _render_snippet($c, $dom, $b));
      }
      when('PagePart') {
        $container -> appendChild($self -> _render_page_part($c, $dom, $b));
      }
    }
  }

  return $container;
}

sub render {
  my($self, $c, $config, $page) = @_;

  # now we want to render $self -> layout and bring in page content
  # as well as snippets along the way
  $c -> stash(page => $page);
  $c -> stash(layout_config => $config);
  $c -> stash(parser => XML::LibXML->new());

  my $dom = XML::LibXML::Document->new();

  my $doc = $self -> _render_box($c, $dom, $self -> layout);
  $doc -> setAttribute(class => "layout-" . $self -> uuid);

  $dom -> setDocumentElement($doc);

  # doesn't have the header stuff in it - we'll want to pass this to
  # the view tt2 template and let it wrap everything in the html5 header stuff
  return $dom -> toStringHTML();
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
