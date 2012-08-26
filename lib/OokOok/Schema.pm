use utf8;
package OokOok::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Schema';

our $VERSION = 2;

__PACKAGE__->load_namespaces;

for my $class (__PACKAGE__ -> sources) {
  "OokOok::Schema::Result::$class" -> meta -> make_immutable(
    inline_constructor => 0
  );
}

# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-05-21 15:39:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sUKIshFTrsfsCwi3JdVYpw

has is_development => (
  is => 'rw',
  isa => 'Bool',
  default => 0,
  lazy => 1,
);

after connection => sub {
  my($self) = @_;

  # If we're SQLite and dbname = :memory:, then deploy
  my $dsn = $self -> storage -> connect_info;
  while(ref $dsn) {
    if(ref $dsn eq 'HASH') {
      $dsn = $dsn->{dsn};
    }
    elsif(ref $dsn eq 'ARRAY') {
      $dsn = $dsn->[0];
    }
    else {
      $dsn = undef;
    }
  }
  if($dsn eq 'dbi:SQLite:dbname=:memory:') {
    $self -> deploy;
    $self -> is_development(1);
  }
};

override deploy => sub {
  my($self) = @_;

  super;

  my $l = $self -> resultset('Library') -> create({
    uuid => 'ypUv1ZbV4RGsjb63Mj8b',
    new_project_prefix => 'r',
    new_theme_prefix => 'r',
  });

  $l -> insert;
  $l -> current_edition -> update({
    name => 'Core',
    description => 'Core tags',
  });
  $l -> current_edition -> close;
};

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
