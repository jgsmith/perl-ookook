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

prop layout => (
  is => 'rw',
  type => 'Str',
  source => sub { $_[0] -> source_version -> layout },
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
  link_fragment => 'page-part',
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

sub page_part {
  my($self, $name) = @_;

  my $pp = $self -> source_version -> page_parts -> find({ name => $name });
  if($pp) {
    return OokOok::Resource::PagePart -> new(
      c => $self -> c,
      date => $self -> date,
      source => $pp
    );
  }
}

sub can_PUT {
  my($self) = @_;

  $self -> project -> can_PUT;
}

sub render {
  my($self, $context) = @_;

  # we want to find the layout we're pointing to and use that to render
  # ourselves
  my $layout_uuid = $self -> source_version -> layout;
  #
  my $theme = $self -> project -> theme;
  return '<p>No Theme</p>' unless $theme;
  my $layout = $theme -> layout( $layout_uuid );
  if($layout) {
    $context = $context -> localize;
    $context -> set_resource(page => $self);
    return $layout -> render($context);
  }
  else {
    return '<p>No Layout</p>';
  }
}

1;
