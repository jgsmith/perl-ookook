use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::BoardMemberApplicant

# ABSTRACT: A board member's comment and vote about a board applicant

Table OokOok::Schema::Result::BoardMemberApplicant {

  prop vote => (
    data_type => 'integer',
    is_nullable => 1,
  );

  prop comments => (
    data_type => 'text',
    is_nullable => 1,
  );

}
