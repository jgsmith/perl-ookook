use CatalystX::Declare;

=head1 NAME

OokOok::Model::ES - ElasticSearch model glue for OokOok

=cut

model OokOok::Model::ES {

  use ElasticSearch;

  method COMPONENT ($self: $app, @rest) {
    my $class = ref $self || $self;
    my $arg = {};
    if( scalar @rest ) {
      if( ref($rest[0]) eq 'HASH' ) {
        $arg = $rest[0];
      }
      else {
        $arg = { @rest };
      }
    }
    $self = $class -> next::method($app, $arg);

    return ElasticSearch->new($class->config||{});
  }
}

1;
