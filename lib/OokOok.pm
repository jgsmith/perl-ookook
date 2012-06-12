package OokOok;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    -Debug
    ConfigLoader
    Static::Simple

    Unicode::Encoding

    Session
    Session::Store::FastMmap
    Session::State::Cookie

    StatusMessage

    StackTrace

    +OokOok::Plugin::Twitter
/;
use CatalystX::RoleApplicator;

extends 'Catalyst';

__PACKAGE__->apply_request_class_roles(qw[
  Catalyst::TraitFor::Request::REST::ForBrowsers
]);

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in ookook.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'OokOok',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header
    encoding => 'UTF-8',
);
__PACKAGE__->config(
    'View::HTML' => {
      INCLUDE_PATH => [
        __PACKAGE__->path_to( qw/root src/ ),
      ],
    },
    'Plugin::ConfigLoader' => {
      file => __PACKAGE__ -> path_to( 'conf' ),
    },
);

# Start the application
__PACKAGE__->setup();

override prepare_path => sub {
  my $c = shift;

  super;

  my @path_chunks = split m[/], $c->request->path, -1;

  return unless @path_chunks;

  my $first = shift @path_chunks;
  if($first eq 'dev') {
    $c -> stash -> {development} = 1;
  }
  elsif($first =~ m{^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$}) {
    $c -> stash -> {date} = DateTime -> new({
      year => $1,
      month => $2,
      day => $3,
      hour => $4,
      minute => $5,
      second => $6
    });
  }
  else {
    unshift @path_chunks, $first;
    $first = '';
  }

  # Create a request path from the remaining chunks:
  my $path = join('/', @path_chunks) || '/';

  # Stuff modified request path back into request:
  $c->request->path($path);

  # Update request base to include whatever
  # was stripped from the request path:
  my $base = $c->request->base;
  $base->path($base->path . $first);
};


=head1 NAME

OokOok - Catalyst based application

=head1 SYNOPSIS

    script/ookook_server.pl

=head1 DESCRIPTION

OokOok is a platform for creating web-based projects.

=head1 SEE ALSO

L<OokOok::Controller::Root>, L<Catalyst>

=head1 AUTHOR

James Smith,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
