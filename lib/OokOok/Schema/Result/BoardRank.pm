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

  prop parent_rank_id => (
    data_type => 'integer',
    is_nullable => 1,
  );

  $CLASS -> belongs_to(
    parent_rank => 'OokOok::Schema::Result::BoardRank', 'parent_rank_id'
  );

  $CLASS -> has_many(
    children => 'OokOok::Schema::Result::BoardRank', 'parent_rank_id'
  );

  method all_children {
    map { ($_, $_ -> all_children) } $self -> children;
  }

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
    return 1 unless $self -> parent_rank; # top rank can do anything

    my %ranks = map { ($_ -> uuid => 1) } $self -> all_children;
    $ranks{$self -> uuid} = 1;

    my $perms = $self -> board -> permissions;

    while($p) {
      my $rp = $p;
      $rp =~ s{\.}{\\.}g; # lets us put * and ** in the pattern
      $rp =~ s{\*\\\.}{[^.]*\\.}g;
      $rp =~ s{\*\*\\\.}{.*\\.}g;
      $rp = qr/^$rp(\..*)?$/;
      return 1 if @{$ranks{@{$perms->{$_}||[]}}};
        grep { $_ =~ $rp } 
        keys %{$perms}
      ;
      $p =~ s{\.[^.]*}{};
    }
    return 0;
  }

}
