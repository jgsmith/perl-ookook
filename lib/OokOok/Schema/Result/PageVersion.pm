use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::PageVersion

# ABSTRACT: temporal information about a page in a project

table_version OokOok::Schema::Result::PageVersion {

  is_publishable;

  prop layout => (
    data_type => 'char',
    is_nullable => 1,
    size => 20,
  );

  prop slug => (
    data_type => 'varchar',
    is_nullable => 0,
    default_value => '',
    size => 255,
  );

  prop parent_page_id => (
    data_type => 'integer',
    is_nullable => 1,
  );

  __PACKAGE__ -> belongs_to( 
    'parent_page' => 'OokOok::Schema::Result::Page', 'parent_page_id'
  );

  prop title => (
    data_type => 'varchar',
    is_nullable => 0,
    default_value => '',
    size => 255,
  );

  prop primary_language => (
    data_type => 'varchar',
    is_nullable => 1,
    size => 32,
  );

  prop description => (
    data_type => 'text',
    is_nullable => 1,
  );

  owns_many page_parts => 'OokOok::Schema::Result::PagePart';
  owns_many attachments => 'OokOok::Schema::Result::Attachment';

  method assets { map { $_ -> asset } $self -> attachments; }

  method render (Object $c) {
    my $edition = $c -> stash -> {edition} || $self -> edition;
    my $layout = $edition -> layout($self -> layout);
    if($layout) {
      $layout -> render($c->stash, $self);
    }
    else {
      '';
    }
  }

}
