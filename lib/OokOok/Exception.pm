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

1;
