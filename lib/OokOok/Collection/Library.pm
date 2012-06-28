package OokOok::Collection::Library;

use OokOok::Collection;
use namespace::autoclean;

sub POST {
  my($self, $json) = @_;

  my $values = $self -> verify($json);

  my $library = $self -> c -> model('DB::Library') -> new_result({});
  $library -> insert;
  $library -> current_edition -> update($json);
  OokOok::Resource::Library -> new(
    source => $library,
    c => $self -> c
  );
}

1;

__END__

