use utf8;
package OokOok::Schema::Result::FunctionSession;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::FunctionSession

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<function_session>

=cut

__PACKAGE__->table("function_session");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 function_id

  data_type: 'integer'
  is_nullable: 0

=head2 uuid

  data_type: 'char'
  is_nullable: 0
  size: 20

=head2 request

  data_type: 'text'
  is_nullable: 0

=head2 created_on

  data_type: 'datetime'
  is_nullable: 0

=head2 expires_on

  data_type: 'datetime'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "function_id",
  { data_type => "integer", is_nullable => 0 },
  "uuid",
  { data_type => "char", is_nullable => 0, size => 20 },
  "request",
  { data_type => "text", is_nullable => 0 },
  "created_on",
  { data_type => "datetime", is_nullable => 0 },
  "expires_on",
  { data_type => "datetime", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-06-03 17:30:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JepKKckn1xmXc81GvB6/Ew


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;