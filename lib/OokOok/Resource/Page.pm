use OokOok::Declare;

# PODNAME: OokOok::Resource::Page

# ABSTRACT: Page REST resource

resource OokOok::Resource::Page {

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

  prop status => (
    is => 'rw',
    type => 'Int',
    source => sub { $_[0] -> source_version -> status },
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
    export => 0,
    source => sub {
      $_[0] -> source_version -> page_parts 
    },
  );

  has_many assets => "OokOok::Resource::Asset", (
    is => 'ro',
    export => 0,
    source => sub { $_[0] -> source_version -> assets },
  );

  after EXPORT ($bag) {
    $bag -> with_data_directory('page_parts', sub {
      for my $pp (@{$self -> page_parts}) {
        $bag -> with_data_directory($pp -> name, sub {
          $pp -> EXPORT($bag);
        });
      }
    });
    # we want a list of associated assets
    my @assets = map { $_ -> id } @{$self -> assets};
    $bag -> add_meta( assets => [ @assets ] );
  }

  method slug_path {
    my $pp = $self -> parent_page;

    if(defined $pp && defined $pp -> slug_path && $pp->slug_path ne '') {
      return $pp -> slug_path . "/" . $self -> slug;
    }
    else {
      return $self -> slug;
    }
  }

  method child_pages {
    # we want all of the pages which have a version in the current edition
    # (or most recent edition) pointing to the id of this page
    return unless defined wantarray;

    my %seen;
    my @children = 
      grep {
        $_ -> source_version -> parent_page -> id == $self -> source -> id
        && !$seen{$_ -> source -> id}++
      }
      map {
        $self -> new( 
          source => $_ -> owner, date => $self -> date, c => $self -> c 
        )
      } $self -> source -> children;
    return @children;
  }  
  
  method get_child_page (Str $slug) {
    my $q = $self -> source -> children -> search( {
      "me.slug" => $slug,
    }, {
      order_by => { -desc => 'me.edition_id' }
    } );
  
    # if we are dev, we want the most recent - otherwise, no later than the
    # current operating edition
    if($self -> c -> stash -> {date}) {
      $q = $q -> search({
        "edition.closed_on" => { "<=" => $self -> c -> stash -> {date} }
      }, {
        join => [qw/edition/]
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

  method resolve_path (@slugs) {
    my $slug = shift @slugs;
    return $self if defined($slug) && $slug eq '';
    if(defined $slug) {
      my $c = $self -> get_child_page($slug);
      return $c unless @slugs;
      return $c -> resolve_path( @slugs ) if $c;
    }
  }


  method page_part (Str $name) {
    my $pp = $self -> source_version -> page_parts -> find({ name => $name });
    if($pp) {
      return OokOok::Resource::PagePart -> new(
        c => $self -> c,
        date => $self -> date,
        source => $pp
      );
    }
  }

  override filter_PUT (HashRef $json) {
    $json = super;
    if(exists($json->{status}) && defined($json->{status})) {
      if(!$self -> project -> has_permission('project.page.status')) {
        # make sure the status is not 'approved'
        if($json->{status} == 0) {
          delete $json->{status};
        }
      }
    }
    $json;
  }

  method can_PUT { 
    $self -> project -> has_permission('project.page.edit'); 
  }

  method can_DELETE { 
    $self -> project -> has_permission('project.page.revert'); 
  }

  override can_GET {
    super && $self -> project -> can_GET;
  }

  method stylesheets {
    my $layout = $self -> get_layout;
    if($layout) {
      return $layout -> stylesheets;
    }
  }

  method get_layout {
    my $theme = $self -> project -> theme;
    return unless $theme;

    my $layout_uuid = $self -> source_version -> layout;
    my $layout;
    if($layout_uuid) {
      $layout = $theme -> layout($layout_uuid);
      if($layout) {
        return $layout;
      }
      if($self -> parent_page) {
        return $self -> parent_page -> get_layout;
      }
    }
    elsif($self -> parent_page) {
      return $self -> parent_page -> get_layout;
    }
  }

  method render (Object $context) {
    # we want to find the layout we're pointing to and use that to render
    # ourselves
    #
    my $theme = $self -> project -> theme;
    return '<p>No Theme</p>' unless $theme;
    my $layout = $self -> get_layout;
    return '<p>No Layout</p>' unless $layout;
  
    if($layout) {
      $context = $context -> localize;
      $context -> set_resource(page => $self);
      $context -> set_resource(top_page => $self);
      return $layout -> render($context);
    }
    else {
      return '<p>No Layout</p>';
    }
  }

  method for_search {
    # we want the primary content page parts - not the sidebar and such
    # eventually, we can make this configurable for the project

    my $data = {};
    my $context = OokOok::Template::Context -> new(
      c => $self -> c,
    );
    
    $context -> set_resource(page => $self);
    $context -> set_resource(project => $self -> project);
  
    for my $pp (@{$self -> page_parts}) {
      $data -> {$pp -> name} = $pp -> render($context),
    }
  
    $data -> {"_title"} = $self -> title;
  
    return $data;
  }
}
