use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::BoardRank

# ABSTRACT: a rank in a board

Table OokOok::Schema::Result::BoardRank {

  with_uuid;

  prop name => (
    data_type => 'varchar',
    is_nullable => 0,
    size => 255
  );

  prop position => (
    data_type => 'integer',
    is_nullable => 0,
  );

  owns_many board_members => 'OokOok::Schema::Result::BoardMember';

=method has_permission (Str $permission)

Returns true if the board rank has the given permission.

A rank has a particular permission if its position is higher than or
equal to the rank required for the permission.

Rank positions are reverse ordered: The highest rank has the lowest
position value (0).

Permissions are composed of dot-separated segments. Any segment may be
C<*> or C<**> to indicate a wildcard for a 1 or 1-or-more arbitrary
segments.

=cut

  method has_permission (Str $p) {
    # we check to see if our rank is less than or equal to the rank
    # required for the particular permission
    my $position = $self -> position;

    return 1 if $position == 0; # top rank always can do anything

    my $board = $self -> board;
    my %ranks = map { $_ -> uuid => $_ -> position } $self -> board -> board_ranks;

    my $perms = $board -> permissions;

    while($p) {
      my $rp = $p;
      $rp =~ s{\.}{\\.}g; # lets us put * and ** in the pattern
      $rp =~ s{\*\\\.}{[^.]*\\.}g;
      $rp =~ s{\*\*\\\.}{.*\\.}g;
      $rp = qr/^$rp(\..*)?$/;
      return 1 if 
        grep { defined($perms -> {$_}) &&
               $ranks{$perms->{$_}} >= $position
             }
        grep { $_ =~ $rp } 
        keys %{$perms}
      ;
      $p =~ s{\.[^.]*}{};
    }
    return 0;
  }

}
