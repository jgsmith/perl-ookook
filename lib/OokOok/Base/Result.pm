package OokOok::Base::Result;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

use namespace::autoclean;

use Data::UUID;

my $ug = Data::UUID -> new;

before insert => sub {
  my($self) = @_;

  if($self -> can('uuid') && !$self -> uuid) {
    my $uuid = substr($ug -> create_b64, 0, 20);
    $uuid =~ tr{+/}{-_};
    $self -> uuid($uuid);
  }
};

1;
