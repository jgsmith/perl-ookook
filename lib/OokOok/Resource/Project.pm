package OokOok::Resource::Project;
use OokOok::Resource;
use namespace::autoclean;
with 'OokOok::Role::Resource::HasEditions';

has '+edition_resource_class' => (
  default => 'OokOok::Resource::Edition',
);

prop name => (
  required => 1,
  type => 'Str',
  source => sub { $_[0] -> source -> current_edition -> name },
  maps_to => 'title',
);

prop id => (
  is => 'ro',
  type => 'Str',
  maps_to => 'id',
  source => sub { $_[0] -> source -> uuid },
);

prop description => (
  type => 'Str',
  source => sub { $_[0] -> source -> current_edition -> description },
);

prop sitemap => (
  type => 'HashRef',
  source => sub { $_[0] -> source -> current_edition -> sitemap },
  verifier => sub { 1 },
  value_type => 'hash',
);

has_many pages => 'OokOok::Resource::Page', (
  is => 'ro',
);

has_many editions => 'OokOok::Resource::Edition', (
  is => 'ro',
);

belongs_to theme => 'OokOok::Resource::Theme', (
  source => sub { $_[0] -> source -> current_edition -> theme },
  is => 'rw',
  maps_to => 'theme',
  value_type => "Theme",
);

belongs_to board => 'OokOok::Resource::Board', (
  source => sub { $_[0] -> source -> board },
  is => 'rw',
  maps_to => 'board',
  value_type => 'Board',
);

sub _walk_sitemaps {
  my($self, $sitemap, $changes) = @_;

  my($k, $v, $kk, $vv);

  while(($k, $v) = each(%$changes)) {
    if(!exists $sitemap->{$k}) {
      $sitemap->{$k} = { };
    }
    while(($kk, $vv) = each(%$v)) {
      if($kk eq 'children') {
        if(!exists $sitemap -> {$k} -> {children}) {
          $sitemap->{$k} -> {children} = {};
        }
        $self -> _walk_sitemaps($sitemap -> {$k} -> {children}, $vv);
        if(0 == scalar(keys %{$sitemap->{$k}->{children}})) {
          delete $sitemap->{$k}->{children};
        }
      }
      elsif(defined $vv) {
        $sitemap -> {$k} -> {$kk} = $vv;
      }
      elsif(exists $sitemap->{$k}->{$kk}) {
        delete $sitemap->{$k}->{$kk};
      }
    }
    if(!scalar(keys(%{$sitemap->{$k}}))) {
      delete $sitemap->{$k};
    }
  }
}

sub PUT {
  my($self, $json) = @_;

  my $values = $self -> verify($json);

  my $sitemap = delete $values->{sitemap};
  if(defined $sitemap) {
    my $old_sitemap = $self -> source -> current_edition -> sitemap;
    $self -> _walk_sitemaps($old_sitemap, $sitemap);
    $values -> {sitemap} = $old_sitemap;
  }

  $self -> source -> current_edition -> update( $values );

  $self;
}

sub can_PUT {
  my($self) = @_;

  # the user has to be in a rank that can modify the project itself
  # if we get here, we have a user
  my $rank = $self -> c -> model('DB::BoardRank') -> search({
    'board.id' => $self -> source -> board -> id,
    'board_members.user_id' => $self -> c -> user -> id,
  }, {
    joins => [qw/board_members board/],
    rows => 1,
  }) -> first;
  return 0 unless $rank;

  return 1 if $rank -> position == 0; # top rank can always do stuff

  return 0;
}

1;
