package OokOok::Resource::Page;
use OokOok::Resource;

prop title => (
  required => 1,
  type => 'Str',
  source => sub { $_[0] -> source -> current_version -> title },
);

prop description => (
  required => 0,
  type => 'Str',
  source => sub { $_[0] -> source -> current_version -> description },
);

prop uuid => (
  is => 'ro',
  type => 'Str',
);

belongs_to project => "OokOok::Resource::Project";

has_many page_parts => "OokOok::Resource::PagePart", 
  source => sub {
    $_[0] -> source -> current_version -> page_parts 
  }
;

1;
