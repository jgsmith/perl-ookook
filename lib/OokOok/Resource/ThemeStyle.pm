use OokOok::Declare;

# PODNAME: OokOok::Resource::ThemeStyle

# ABSTRACT: Theme Style REST Resource

resource OokOok::Resource::ThemeStyle {

  belongs_to 'theme' => 'OokOok::Resource::Theme', (
    is => 'ro',
    required => 1,
    source => sub { $_[0] -> source -> theme },
  );

  #has_many 'theme_layouts' => 'OokOok::Resource::ThemeLayout', (
  #  is => 'ro',
  #  source_version => sub { $_[0] -> source -> theme_layout_versions },
  #);

  prop id => (
    is => 'ro',
    type => 'Str',
    source => sub { $_[0] -> source -> uuid },
  );

  prop name => (
    is => 'rw',
    type => 'Str',
    required => 1,
    source => sub { $_[0] -> source_version -> name },
  );

  prop styles => (
    is => 'rw',
    isa => 'Str',
    required => 1,
    source => sub { $_[0] -> source_version -> styles },
    export_as_file => 'content'
  );

  method can_PUT {
    $self -> theme -> has_permission('theme.style.edit');
  }

  method can_DELETE {
    $self -> theme -> has_permission('theme.style.revert');
  }

  method get_asset_url (Object $context, Str $name) {
    # either we have it or the project has it, but we reference it through the
    # theme's uuid -- the style provider will figure things out
    my $asset = $self -> theme -> asset($name) or return '';

    my $project = $context -> get_resource('project');
    if($project) {
      $self -> c -> uri_for('/s/' . $project -> id . '/asset/' . $asset -> id);
    }
    else {
      $self -> c -> uri_for('/ts/' . $self -> theme -> id . '/asset/' . $asset -> id);
    }
  }

  method render (Object $context) {
    # we need to translate any asset references...
    # things like asset($name)
    my $content = $self -> styles;
    my @assets = keys %{ +{ map { $_ => 1 } $content =~ m{asset\((.*?)\)}gs } };
    my %assets = map { $_ => "url(".$self->get_asset_url($context,$_).")" } @assets;
    $content =~ s{asset\((.*?)\)}{$assets{$1}}ge;
    $content;
  }
}
