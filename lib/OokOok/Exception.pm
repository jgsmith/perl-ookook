use MooseX::Declare;

class OokOok::Exception extends Throwable::Error is mutable {
  has status => ( is => 'ro', isa => 'Int', default => 400 );

  method bad_request (Object|ClassName $self: %args) 
                     { $self -> throw( %args, status => 400 ) }
  method forbidden   (Object|ClassName $self: %args) 
                     { $self -> throw( %args, status => 403 ) }
  method not_found   (Object|ClassName $self: %args) 
                     { $self -> throw( %args, status => 404 ) }
  method gone        (Object|ClassName $self: %args) 
                     { $self -> throw( %args, status => 410 ) }
}

class OokOok::Exception::DELETE extends OokOok::Exception is mutable;

class OokOok::Exception::GET extends OokOok::Exception is mutable;

class OokOok::Exception::PUT extends OokOok::Exception is mutable {

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

}

class OokOok::Exception::POST extends OokOok::Exception::PUT is mutable;

class OokOok::Exception::OAIPMH extends Throwable::Error is mutable {
  use CLASS;

  has code => ( is => 'ro', isa => 'Str', required => 1 );

  my %messages = (
    badVerb => 'Illegal OAI verb',
    badArgument => '',
    cannotDisseminateFormat => '',
    noMetadataFormats => '',
    idDoesNotExist => 'No matching identifier in this repository',
    noSetHierarchy => 'This repository does not support sets',
    badResumptionToken => '',
    noRecordsMatch => '',
  );

  for my $method (keys %messages) {
    $CLASS -> meta -> add_method( $method => sub {
      my($self, %args) = @_;
      $self -> throw(
        message => $messages{$method},
        %args,
        code => $method
      );
    } );
  }
}
