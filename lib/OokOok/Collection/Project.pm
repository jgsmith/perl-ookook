package OokOok::Collection::Project;

use OokOok::Collection;
use namespace::autoclean;

sub POST {
  my($self, $json) = @_;

  my $values = $self -> verify($json);

  my $project = $self -> c -> model('DB::Project') -> new_result({});
  $project -> insert;
  $project -> current_edition -> update($json);
  OokOok::Resource::Project -> new(
    source => $project,
    c => $self -> c
  );
}


1;

__END__
