use CatalystX::Declare;
use 5.012;

application OokOok
  with ConfigLoader
  with Static::Simple

  with Unicode::Encoding

  with Params::Nested

  with Session
  with Session::Store::FastMmap
  with Session::State::Cookie
  #with Session::PerUser

  with StatusMessage

  with StackTrace
  with OokOok::Authentication
{

  use CatalystX::RoleApplicator;
  use DateTime;

  $CLASS -> apply_request_class_roles(qw[
    Catalyst::TraitFor::Request::REST::ForBrowsers
  ]);

  our $VERSION = '0.01';
  $VERSION = eval $VERSION;

  $CLASS->config(
    name => 'OokOok',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header
    encoding => 'UTF-8',
    default_view => 'Mason',
    'Plugin::ConfigLoader' => {
      file => $CLASS -> path_to( 'conf' ),
    },
  );

  override prepare_path ($ctx:) {
    super;

    my @path_chunks = split m[/], $ctx->request->path, -1;

    return unless @path_chunks;

    my $first = shift @path_chunks;
    if($first eq 'dev') {
      $ctx -> stash -> {development} = 1;
    }
    elsif($first =~ m{^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$}) {
      $ctx -> stash -> {date} = DateTime -> new({
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
    $ctx->request->path($path);
  
    # Update request base to include whatever
    # was stripped from the request path:
    my $base = $ctx->request->base;
    $base->path($base->path . $first);
  };
}

__END__

=head1 NAME

OokOok - Content Management System for scholarly editions

=head1 SYNOPSIS

    script/ookook_server.pl

=head1 DESCRIPTION

OokOok is a platform for creating scholarly web-based projects.

=head1 CONFIGURATION

In addition to the standard Catalyst configuration options, OokOok has the
following sections.

=head2 TagLibs

The C<TagLibs> section lets you configure the Perl modules that provide
implementations for tag libraries. These tag libraries need additional
configuration in the database before they can be used in projects or
themes.

For example:

 <TagLibs>
   <module OokOok::Template::TagLibrary::Core>
     namepsace uin:uuid:ypUv1ZbV4RGsjb63Mj8b
   </module>
 </TagLibs>

=head1 SEE ALSO

L<OokOok::Controller::Root>, L<Catalyst>

=head1 AUTHOR

James Smith,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
