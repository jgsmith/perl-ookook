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
    ElasticSearch -> new( %{OokOok -> config -> {'Model::Search'} -> {connect_info}||{}} );
  }

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
