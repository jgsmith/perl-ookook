use OokOok::Declare;

# PODNAME: OokOok::Schema::Result::ApiKey

# ABSTRACT: ApiKey database row

Table OokOok::Schema::Result::ApiKey {

  prop token => (
    data_type => 'varchar',
    is_nullable => 0,
    size => 255,
  );

  prop token_secret => (
    data_type => 'varchar',
    is_nullable => 0,
    size => 255,
  );

}
