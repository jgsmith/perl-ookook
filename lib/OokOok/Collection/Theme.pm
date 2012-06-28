package OokOok::Collection::Theme;

use OokOok::Collection;
use namespace::autoclean;

sub POST {
  my($self, $json) = @_;

  my $values = $self -> verify($json);

  my $theme = $self -> c -> model('DB::Theme') -> new_result({});
  $theme -> insert;
  $theme -> current_edition -> update($json);
  OokOok::Resource::Theme -> new(
    source => $theme,
    c => $self -> c
  );
}

1;

__END__

