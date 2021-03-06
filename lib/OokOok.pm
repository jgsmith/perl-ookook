use CatalystX::Declare;
use 5.012;

# PODNAME: OokOok

# ABSTRACT: Temporal Content and Data Management System

=head1 SYNOPSIS

    script/ookook_server.pl

=head1 DESCRIPTION

OokOok is a platform for creating scholarly web-based projects.

=cut

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

  __PACKAGE__ -> apply_request_class_roles(qw[
    Catalyst::TraitFor::Request::REST::ForBrowsers
  ]);

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
   <module OokOok::TagLibrary::Core>
     namepsace uin:uuid:ypUv1ZbV4RGsjb63Mj8b
   </module>
 </TagLibs>

=cut

  __PACKAGE__->config(
    name => 'OokOok',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header
    encoding => 'UTF-8',
    default_view => 'Mason',
    'Plugin::ConfigLoader' => {
      file => __PACKAGE__ -> path_to( 'conf' ),
    },
  );

=method transaction_guard ()

Returns a guard object. If the object goes out of scope before its
C<commit> method is called, then the transaction will be rolled back.
This only works with the PostgreSQL database for now.

=cut

  method transaction_guard {
    $self -> model('DB') -> txn_scope_guard;
  }

=method prepare_path ()

OokOok will check the first component of the request path. If it
is C<dev>, then the request is marked as pertaining to the development
version of the resource, asset, or page. If it is a sequence of
fourteen (14) digits, then it is parsed as a date and time
(yyyymmddhhmmss) indicating the date and time of the version of the
resource, asset, or page.

If the first component is neither C<dev> nor a date and time, then the
path is left unchanged.

=cut

  #my $formatter = OokOok::DateTime::Parser -> new;

  override prepare_path ($ctx:) {
    super;

    my @path_chunks = split m[/], $ctx->request->path, -1;

    return unless @path_chunks;

    my $first = shift @path_chunks;
    given($first) {
      when('dev') {
        $ctx -> stash -> {mode} = 'development';
        # Update request base to include whatever
        # was stripped from the request path:
        my $base = $ctx->request->base;
        $base->path($base->path . $first);
      }
      when('timegate') {
        $ctx -> stash -> {mode} = 'timegate';
        # if HEAD/GET, then we want to look for Accept-Datetime header
        
      }
      when('timemap') {
        $ctx -> stash -> {mode} = 'timemap';
        # if HEAD/GET, then we want to look for Accept-Datetime header?
      }
      default {
        if(length($first) == 14 && $first =~ m{^\d+$}) {
          $ctx -> stash -> {mode} = 'dated';
          $ctx -> stash -> {date} = OokOok::DateTime::Parser -> parse_datetime($first);
          $ctx -> stash -> {date} -> set_formatter('OokOok::DateTime::Parser');
          $ctx -> response -> header( 'Momento-Datetime' => $ctx -> stash -> {date} -> strftime("%a, %d %b %Y %H:%M:%S %z") );
        }
        else {
          $ctx -> stash -> {mode} = 'current';
          #$ctx -> stash -> {date} = DateTime -> now;
          #$ctx -> stash -> {date} -> set_formatter('OokOok::DateTime::Parser');
          unshift @path_chunks, $first;
          $first = '';
        }
        # Update request base to include whatever
        # was stripped from the request path:
        my $base = $ctx->request->base;
        $base->path($base->path . $first);
      }
    }
  
    # Create a request path from the remaining chunks:
    my $path = join('/', @path_chunks) || '/';
  
    # Stuff modified request path back into request:
    $ctx->request->path($path);
  
  }

=method formatters ()

Returns the list of formatter classes available.

=cut

  our @FORMATTERS;
  our @TAGLIBRARIES;

  method formatters (Object|ClassName $self:) {
    return @FORMATTERS if @FORMATTERS;
    @FORMATTERS = $self -> _formatters;
  }

  method taglibraries (Object|ClassName $self:) {
    return @TAGLIBRARIES if @TAGLIBRARIES;
    @TAGLIBRARIES = $self -> _taglibs;
    for my $taglib (@TAGLIBRARIES) {
      if($self -> config -> {TagLibs} -> {module} -> {$taglib} -> {namespace}){
        $taglib -> meta -> taglib_namespace(
          $self -> config -> {TagLibs} -> {module} -> {$taglib} -> {namespace}
        );
      }
    }
    @TAGLIBRARIES;
  }

}

BEGIN {
  package OokOok;
  use OokOok::DateTime::Parser ();
  use Module::Pluggable (search_path => 'OokOok::Formatter', 
                         sub_name => '_formatters',
                         require => 1,
                         max_depth => 3);
  use Module::Pluggable (search_path => 'OokOok::TagLibrary', 
                         sub_name => '_taglibs',
                         require => 1,
                         max_depth => 4);

  __PACKAGE__ -> _formatters;
  __PACKAGE__ -> _taglibs;
  #print STDERR "Formatters: \n  ", join("\n  ", __PACKAGE__ -> _formatters), "\n";
}

1;



__END__

=head1 SEE ALSO

=for :list
* L<OokOok::Controller::Root>
* L<Catalyst>

=cut
