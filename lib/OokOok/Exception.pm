package OokOok::Exception;

use Moose;
extends 'Throwable::Error';

use namespace::autoclean;

has status => (
  is => 'ro',
  isa => 'Int',
  default => 400,
);

sub bad_request { shift -> throw( @_, status => 400 ) }
sub forbidden   { shift -> throw( @_, status => 403 ) }
sub not_found   { shift -> throw( @_, status => 404 ) }
sub gone        { shift -> throw( @_, status => 410 ) }

package OokOok::Exception::PUT;

use Moose;
extends 'OokOok::Exception';
use namespace::autoclean;

has missing => (
  is => 'ro',
  isa => 'ArrayRef',
  required => 0,
  predicate => 'has_missing',
);

has invalid => (
  is => 'ro',
  isa => 'ArrayRef',
  required => 0,
  predicate => 'has_invalid',
);

package OokOok::Exception::POST;

use Moose;
extends 'OokOok::Exception::PUT';
use namespace::autoclean;

package OokOok::Exception::OAIPMH;

use Moose;
extends 'Throwable::Error';

has code => (
  is => 'ro',
  isa => 'Str',
  required => 1,
);

sub badVerb {
  shift -> throw( 
    message => "Illegal OAI verb", @_,
    code => 'badVerb' 
  ) 
}
sub badArgument  {
  shift -> throw( 
    message => '',
    @_, 
    code => 'badArgument' 
  )
}
sub cannotDisseminateFormat {
  shift -> throw( 
    message => '',
    @_, 
    code => 'cannotDisseminateFormat' 
  )
}
sub noMetadataFormats {
  shift -> throw( 
    message => '',
    @_, 
    code => 'noMetadataFormats' 
  )
}
sub idDoesNotExist  {
  shift -> throw( 
    message => 'No matching identifier in this repository', @_, 
    code => 'idDoesNotExist' 
  )
}
sub noSetHierarchy {
  shift -> throw( 
    message => "This repostory does not support sets", @_,
    code => "noSetHierarchy" 
  )
}
sub badResumptionToken {
  shift -> throw(
    message => '', @_,
    code => 'badResumptionToken'
  )
}
sub noRecordsMatch {
  shift -> throw(
    message => '', @_,
    code => 'noRecordsMatch'
  )
}

1;
