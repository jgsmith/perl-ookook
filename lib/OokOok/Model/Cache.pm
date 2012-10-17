use CatalystX::Declare;

# PODNAME: OokOok::Model::Cache

# ABSTRACT: CHI model glue for OokOok

model OokOok::Model::Cache {

  use CHI;

  has _cache => (
    is => 'rw',
    isa => 'Object',
    builder => '_build_cache',
    handles => [qw/
      compute get set
    /],
  );

  method _build_cache {
    CHI->new( 
      %{OokOok -> config -> {'Model::Cache'}||{}} 
    );
  }
}

