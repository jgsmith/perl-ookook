use MooseX::Declare;
use 5.008008;

class OokOok::Declare extends CatalystX::Declare is dirty is mutable {

  use aliased 'OokOok::Declare::Keyword::RESTController', 'RESTControllerKeyword';
  use aliased 'OokOok::Declare::Keyword::PlayController', 'PlayControllerKeyword';
  use aliased 'OokOok::Declare::Keyword::AdminController', 'AdminControllerKeyword';
  use aliased 'OokOok::Declare::Keyword::Resource',       'ResourceKeyword';
  #use aliased 'OokOok::Declare::Keyword::Collection',     'CollectionKeyword';
  #use aliased 'OokOok::Declare::Keyword::Table',          'TableKeyword';
  #use aliases 'OokOok::Declare::Keyword::EditionedTable', 'EditionedTableKeyword';
  #use aliases 'OokOok::Declare::Keyword::VersionedTable', 'VersionedTableKeyword';

  clean;

  our $VERSION = '0.01';

  around keywords (ClassName $self:) {
    $self->$orig,

    RESTControllerKeyword->new( identifier => 'rest_controller' ),
    PlayControllerKeyword->new( identifier => 'play_controller' ),
    AdminControllerKeyword->new( identifier => 'admin_controller' ),
    ResourceKeyword->new(       identifier => 'resource' ),
    #CollectionKeyword->new(     identifier => 'collection' ),
    #TableKeyword->new(          identifier => 'table' ),
    #EditionedTableKeyword->new( identifier => 'editioned_table' ),
    #VersionedTableKeyword->new( identifier => 'versioned_table' ),
  }
}

__END__

=head1 NAME

OokOok::Declare - EXPERIMENTAL Declarative Syntax for OokOok Components

=head1 SYNOPSIS


