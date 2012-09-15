use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::User

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

  owns_many oauth_identities => 'OokOok::Schema::Result::OauthIdentity';
  owns_many board_members    => 'OokOok::Schema::Result::BoardMember';
  owns_many board_applicants => 'OokOok::Schema::Result::BoardApplicant';
  owns_many emails           => 'OokOok::Schema::Result::Email';

  $CLASS -> many_to_many( board_ranks => 'board_members', 'board_rank' );

  method may_design { $self -> is_admin; }

}
