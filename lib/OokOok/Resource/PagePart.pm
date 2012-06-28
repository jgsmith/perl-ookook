package OokOok::Resource::PagePart;
use OokOok::Resource;

prop name => (
  required => 1,
  max_length => 64,
  type => 'Str',
);

prop content => (
  required => 0,
  type => 'Str',
  deep => 1,
);

belongs_to "page" => "OokOok::Resource::Page";

1;

__END__
