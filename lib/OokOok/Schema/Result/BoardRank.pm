use utf8;
package OokOok::Schema::Result::BoardRank;

=head1 NAME

OokOok::Schema::Result::BoardRank

=cut

use OokOok::Result;
use namespace::autoclean;

prop name => (
  data_type => 'varchar',
  is_nullable => 0,
  size => 255
);

prop position => (
  data_type => 'integer',
  is_nullable => 0,
);

prop may_vote_on_induction => (
  data_type => 'boolean',
  default_value => 0,
  is_nullable => 0,
);

prop permissions => (
  data_type => 'text',
  is_nullable => 1,
  inflate => sub { eval { JSON->decode(shift||'{}') } },
  deflate => sub { eval { JSON->encode(shift|| {} ) } },
);
  
sub has_permission {
  my($self, $p) = @_;

  while($p) {
    return 1 if $self -> permissions -> {$p};
    $p =~ s{\.[^.]*$}{};
  }
  return 0;
}

1;
