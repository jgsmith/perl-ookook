use utf8;
package OokOok::Schema::Result::BoardApplicant;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OokOok::Schema::Result::BoardApplicant

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

=head1 TABLE: C<board_applicant>

=cut

__PACKAGE__->table("board_applicant");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 uuid

  data_type: 'char'
  is_nullable: 1
  size: 20

=head2 user_id

  data_type: 'integer'
  is_nullable: 0

=head2 board_id

  data_type: 'integer'
  is_nullable: 0

=head2 status

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 vote_deadline

  data_type: 'datetime'
  is_nullable: 1

=head2 application

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "uuid",
  { data_type => "char", is_nullable => 1, size => 20 },
  "user_id",
  { data_type => "integer", is_nullable => 0 },
  "board_id",
  { data_type => "integer", is_nullable => 0 },
  "status",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "vote_deadline",
  { data_type => "datetime", is_nullable => 1 },
  "application",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-08-09 11:53:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6tQiAHpuEuCjSU/5xW2SQA

with 'OokOok::Role::Schema::Result::UUID';

# denied, accepted, vote in progress, preliminary
my @status = ['preliminary', 'vote in progress', 'denied', 'accepted'];
my %status = map { $status[$_] => $_ } 0..$#status;

__PACKAGE__ -> inflate_column( status => {
  inflate => sub { 
    my($status,$self) = @_;
    $status = $status[$status] || 'unknown';
    if($status eq 'vote in progress' && $self -> vote_deadline &&
         $self -> vote_deadline < DateTime->now) {
      $status = 'vote concluded';
    }
    $status;
  },
  deflate => sub { 
    my($status, $self) = @_;
    if($status eq 'vote concluded') {
      $status = 'vote in progress';
    }
    $status{$status} || -1;
  },
});

__PACKAGE__ -> belongs_to( board => 'OokOok::Schema::Result::Board', 'board_id' );
__PACKAGE__ -> belongs_to( user => 'OokOok::Schema::Result::User', 'user_id' );


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
