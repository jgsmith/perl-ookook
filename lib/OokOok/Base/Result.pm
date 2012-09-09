use MooseX::Declare;

# PODNAME: OokOok::Base::Result

class OokOok::Base::Result extends DBIx::Class::Core {

  use MooseX::NonMoose;
  use MooseX::MarkAsMethods autoclean => 1;

  use Data::UUID;

  my $ug = Data::UUID -> new;

  before insert {
    if($self -> can('uuid') && !$self -> uuid) {
      my $uuid = substr($ug -> create_b64, 0, 20);
      $uuid =~ tr{+/}{-_};
      $self -> uuid($uuid);
    }
  }

}
