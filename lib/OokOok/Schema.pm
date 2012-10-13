use utf8;
package OokOok::Schema;

# ABSTRACT: A database schema for OokOok

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Schema';

# the schema version - not the OokOok package version
our $VERSION = 5;

__PACKAGE__->load_namespaces;

for my $class (__PACKAGE__ -> sources) {
  "OokOok::Schema::Result::$class" -> meta -> make_immutable(
    inline_constructor => 0
  );
}

has is_development => (
  is => 'rw',
  isa => 'Bool',
  default => 0,
  lazy => 1,
);

=method connection ()

OokOok extends the default L<DBIx::Class::Schema> method to automatically
deploy the schema if the DSN is equal to C<dbi:Pg:dbname=ookook_testing>.

=cut

after connection => sub {
  my($self) = @_;

  # If we're PostgreSQL and dbname = 'ookook_testing', then deploy
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
  if($dsn eq 'dbi:Pg:dbname=ookook_testing') {
    $self->storage->dbh_do(
      sub {
        my ($storage, $dbh, @args) = @_;
        $dbh->do("SET client_min_messages=error");
      }
    );

    $self -> deploy({
      add_drop_table => 1,
    });
    $self -> is_development(1);
  }
};

=method deploy ()

OokOok extends the default L<DBIx::Class::Schema> method to add the
core tag library with the uuid C<ypUv1ZbV4RGsjb63Mj8b>.

This mirrors the example configuration in L<OokOok>.

=cut

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

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
