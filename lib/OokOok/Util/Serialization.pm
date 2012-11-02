package OokOok::Util::Serialization;

# ABSTRACT: Serialization utilities

use parent 'Exporter';

our @EXPORT_OK = qw(to_link_format);

sub to_link_format {
  join(",\n", map {
    my $l = $_;
    join(";", '<' . $l->{link} . '>',
      map {
        $_ eq 'link' ? ()
                     : $_ . '="' . $l->{$_} . '"'
      } keys %$l
    )
  } @_ );
}

1;
