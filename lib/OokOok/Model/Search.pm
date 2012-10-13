use CatalystX::Declare;

# PODNAME: OokOok::Model::Search

# ABSTRACT: ElasticSearch model glue for OokOok

model OokOok::Model::Search {

  use ElasticSearch;

  has _es => (
    is => 'rw',
    isa => 'Object',
    builder => '_build_es',
    handles => [qw/
      scroll
      query_parser
      search
    /],
  );

  method _build_es {
    ElasticSearch -> new( $CLASS -> config -> {connect_info}||{} );
  }

  #method COMPONENT ($self: $app, @rest) {
  #  my $class = ref $self || $self;
  #  my $arg = {};
  #  if( scalar @rest ) {
  #    if( ref($rest[0]) eq 'HASH' ) {
  #      $arg = $rest[0];
  #    }
  #    else {
  #      $arg = { @rest };
  #    }
  #  }
  #  $self = $class -> next::method($app, $arg);
  #
  #  return ElasticSearch->new($class->config->{connect_info}||{});
  #}

  method index (ArrayRef :$docs, :$index, :$lang = 'en') {
    $self -> _es -> bulk_index(
      docs => $docs,
      index => $index, # We ignore language for now
      consistency => 'quorum',
      replication => 'async',
      on_conflict => 'IGNORE',
      on_error => 'IGNORE',
    );
  }
}
