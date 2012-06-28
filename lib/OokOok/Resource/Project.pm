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
);

prop uuid => (
  is => 'ro',
  type => 'Str',
);

prop description => (
  type => 'Str',
  source => sub { $_[0] -> source -> current_edition -> description },
);

prop sitemap => (
  type => 'HashRef',
  source => sub { $_[0] -> source -> current_edition -> sitemap },
  verifier => sub { 1 },
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

1;
