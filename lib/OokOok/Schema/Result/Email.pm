use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::Email;

# ABSTRACT: an email address and related information

Table OokOok::Schema::Result::Email {

  prop verified => (
    data_type => 'boolean',
    default_value => 0,
    is_nullable => 0,
  );

  prop email => (
    data_type => 'varchar',
    is_nullable => 0,
    size => 255,
    unique => 1,
  );

}
