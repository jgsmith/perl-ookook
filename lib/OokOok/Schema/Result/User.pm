use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::User

# ABSTRACT: User record in the relational database

Table OokOok::Schema::Result::User {

  with_uuid;

  prop lang => (
    data_type => 'varchar',
    is_nullable => 1,
    size => 8,
  );

  prop name => (
    data_type => 'varchar',
    is_nullable => 1,
    size => 255,
  );

  prop url => (
    data_type => 'varchar',
    is_nullable => 1,
    size => 255,
  );

  prop timezone => (
    data_type => 'varchar',
    is_nullable => 1,
    size => 255,
  );

  prop is_admin => (
    data_type => 'boolean',
    is_nullable => 0,
    default_value => 0,
  );

  prop description => (
    data_type => 'text',
    is_nullable => 1,
  );

  prop experience => (
    data_type => 'integer',
    is_nullable => 0,
    default_value => 0,
  );

  prop spendable_karma => (
    data_type => 'integer',
    is_nullable => 0,
    default_value => 0,
  );

  owns_many oauth_identities => 'OokOok::Schema::Result::OauthIdentity';
  owns_many board_members    => 'OokOok::Schema::Result::BoardMember';
  owns_many board_applicants => 'OokOok::Schema::Result::BoardApplicant';
  owns_many emails           => 'OokOok::Schema::Result::Email';

  $CLASS -> many_to_many( board_ranks => 'board_members', 'board_rank' );

  method board_membership (Object $board) {
    $self -> board_members -> find({
      'board_rank.board_id' => $board -> id
    }, {
      join => 'board_rank'
    });
  }

=method may_design ()

Returns true if the user may create themes. Since themes have special
requirements, designing new themes is restricted.

=cut

  method may_design { $self -> is_admin; }

=method has_permission (Maybe[Object] $board, Str $permission)

Returns true if the user has the appropriate permission with the given
board.

If the user is a system administrator, then they have all permissions.

If the user is not a member of the board, then they will have no
permissions. Resources that should be publicly available should not
require any permissions.

See L<OokOok::Schema::Result::BoardRank> for more information.

=cut

  method has_permission (Maybe[Object] $board, Str $permission) {
    # admins can do anything
    return 1 if $self -> is_admin;

    return 0 unless $board;

    # need to find membership, then do query
    my $membership = $self -> board_membership;

    return 0 unless $membership;

    return $membership -> board_rank -> has_permission($permission);
  }
}
