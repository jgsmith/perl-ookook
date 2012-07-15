package OokOok::Resource::Page;
use OokOok::Resource;

use namespace::autoclean;

has '+source' => (
  isa => 'OokOok::Model::DB::Page',
);

prop title => (
  required => 0,
  type => 'Str',
  source => sub { $_[0] -> source_version -> title },
);

prop slug => (
  type => 'Str',
  required => 0,
  source => sub { $_[0] -> source_version -> slug },
);

prop description => (
  required => 0,
  type => 'Str',
  source => sub { $_[0] -> source_version -> description },
);

prop id => (
  is => 'ro',
  type => 'Str',
  source => sub { $_[0] -> source -> uuid },
);

belongs_to project => "OokOok::Resource::Project", (
  required => 1, # can't be created without one
  is => 'ro',    # once created, it can't be changed
  source => sub { $_[0] -> source -> project }
);

belongs_to parent_page => 'OokOok::Resource::Page', (
  is => 'rw',
  source => sub { $_[0] -> source_version -> parent_page },
);

has_many page_parts => "OokOok::Resource::PagePart", (
  source => sub {
    $_[0] -> source_version -> page_parts 
  },
);

sub get_child_page {
  my($self, $slug) = @_;

  my $q = $self -> source -> children -> search( {
    "me.slug" => $slug,
  }, {
    order_by => { -desc => 'me.edition_id' }
  } );

  # if we are dev, we want the most recent - otherwise, no later than the
  # current operating edition
  if($self -> c -> stash -> {date}) {
    $q = $q -> search({
      "edition.closed_on" => { "<=", $self -> c -> stash -> {date} }
    }, {
      joins => [qw/edition/]
    });
  }
  
  # the one we want is the first one since it's the most recent one with the
  # slug and pointing to us - and in the scope of the edition we're looking
  # at
  my $version = $q -> first;
  if($version) {
    $self -> new(
      c => $self -> c,
      source => $version -> page
    );
  }
}  

sub render {
  my($self, $context) = @_;

  # we want to find the layout we're pointing to and use that to render
  # ourselves
  my $layout_uuid = $self -> source_version -> layout;
  #
  my $theme = $self -> project -> source_version -> theme_edition;
  return '' unless $theme;
  my $layout = $theme -> theme -> layouts( $layout_uuid );
  if($layout) {
    $layout = $layout -> version_for_date( $theme -> closed_on );
    if($layout) {
      $context = $context -> localize;
      $context -> set_resource(page => $self);
      $layout -> render($context);
    }
  }
}

1;
