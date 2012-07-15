package OokOok::Role::Schema::Result::UUID;

use Moose::Role;
use namespace::autoclean;
use Data::UUID;

my $ug = Data::UUID -> new;

before insert => sub {
  my($self) = @_;

  if(!$self -> uuid) {
    my $uuid = substr($ug -> create_b64, 0, 20);
    $uuid =~ tr{+/}{-_};
    $self -> uuid($uuid);
  }
};

1;

