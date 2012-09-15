use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::Board

# ABSTRACT: a governing board

Table OokOok::Schema::Result::Board {

  with_uuid;

  prop name => (
    data_type => 'varchar',
    is_nullable => 0,
    size => 255,
  );

  prop auto_induct => (
    data_type => 'boolean',
    default_value => 0,
    is_nullable => 0,
  );

  owns_many board_ranks => 'OokOok::Schema::Result::BoardRank';
  owns_many board_members => 'OokOok::Schema::Result::BoardMember';
  owns_many board_applicants => 'OokOok::Schema::Result::BoardApplicant';
}
