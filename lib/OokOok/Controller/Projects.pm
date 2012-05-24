package OokOok::Controller::Projects;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::HTML::FormFu'; }

=head1 NAME

OokOok::Controller::Projects - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub list :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c -> load_status_msgs;

    $c -> stash(projects => [$c->model('DB::Project')->all]);
    $c -> stash(template => 'projects/list.tt2');
}

=head2 create

=cut

sub create :Path('create') :Args(0) :FormConfig {
  my($self, $c) = @_;

  my $form = $c -> stash -> {form};

  if($form -> submitted_and_valid) {
    my $project = $c -> model("DB::Project") -> new_result({});
    $form -> model -> update($project);
    my $edition = $project -> current_edition;
    $form -> model -> update($edition);

    $c -> response -> redirect($c -> uri_for($self->action_for('list'),
      { mid => $c -> set_status_msg("Project created") }
    ));
    $c -> detach;
  }
  else {
  }

  $c -> stash(template => 'projects/create.tt2');
}


=head1 AUTHOR

James Smith,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
