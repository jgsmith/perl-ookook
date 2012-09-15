use OokOok::Declare;

# PODNAME: OokOok::Resource::Asset

# ABSTRACT: Project Asset REST Resource

resource OokOok::Resource::Asset {

  has '+source' => (
    isa => 'OokOok::Model::DB::Asset',
  );

  after EXPORT ($bag) {
    # add asset content
  }
}
