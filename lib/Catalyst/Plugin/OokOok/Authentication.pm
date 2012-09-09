use MooseX::Declare;

# PODNAME: Catalyst::Plugin::OokOok::Authentication

# ABSTRACT: Provides OAuth authentication to OokOok

class Catalyst::Plugin::OokOok::Authentication {
  use Net::OAuth::Client;
  use String::Random qw/ random_string /;
  use LWP::UserAgent;
  use HTTP::Request::Common;

  has _user => (
    is => 'rw',
    isa => 'Maybe[Object]',
    lazy => 1,
    default => sub {
      my($c) = @_;

      my $header = $c -> request -> header('X-OokOokSysAuth');
      my $passwd = $c -> config -> {'Plugin::OokOok::Authentication'}->{system_password};

      if($c -> session -> {user_id}) {
        return $c -> model('DB::User') -> find({ id => $c -> session -> {user_id} });
      }
      elsif(defined($header) && defined($passwd) && $header eq $passwd && $c -> config -> {'Plugin::OokOok::Authentication'}->{system_user_enabled}) {
        return $c -> model('DB::User') -> find({ id => 1 });
      }
      elsif($c -> model('DB') -> schema -> is_development) {
        my $user = $c -> model('DB::User') -> find_or_create({
          uuid => 'cookeddeadbeafstasty',
          is_admin => 1,
        });
        return $user;
      }
      else {
        # check request headers for API keys - we don't store anything in the
        # session, so these are needed on each request
      }
    },
  );

=method user (Object $user?)

=cut

  method user ($user?) {
    if($user) {
      $self -> _user($user);
      if(defined $user) {
        $self -> session -> {user_id} = $user -> id;
      }
      else {
        delete $self -> session -> {user_id};
      }
    }
    $self -> _user;
  }

=method authenticate (Str $provider)

=cut

  method authenticate (Str $provider_name) {
    my $provider = $self -> config -> {'Plugin::OokOok::Authentication'} -> {providers} -> {$provider_name};
    return unless $provider;

    my($consumer_key, $consumer_secret) = 
      @{$provider}{qw/consumer_key consumer_secret/};

    my %defaults = (
      site => $provider -> {site},
      request_token_path => $provider -> {request_token_path},
      access_token_path => $provider -> {access_token_path},
      authorize_path => $provider -> {authorize_path},
      callback => $self -> uri_for( 
        $self -> action, 
        $self -> req -> captures, 
        @{ $self -> req -> args } 
      )->as_string,
      session => sub { 
        if(@_ == 1) { $self -> session -> {$_[0]} }
        else { $self -> session(@_) }
      },
    );
  
    my $client = Net::OAuth::Client->new(
      $consumer_key, $consumer_secret,
      %defaults,
      debug => 1,
    );
  
    my $oauth_token = $self -> req -> method eq 'GET'
       ? $self -> req -> query_params -> {oauth_token}
       : $self -> req -> body_params -> {oauth_token};
    my $oauth_verifier = $self -> req -> method eq 'GET'
       ? $self -> req -> query_params -> {oauth_verifier}
       : $self -> req -> body_params -> {oauth_verifier};
  
    if($oauth_token) {
      my $access_token = $client -> get_access_token(
           $oauth_token, $oauth_verifier
      );
  
      # clean up session
      delete $self -> session -> {$oauth_token};
  
      my $info = {
        token_secret => $access_token -> token_secret,
        token => $access_token -> token,
      };
  
      # here, we need to go back to the service and get info about the user
      # so we can identify them
  
      # do these explicitely until we figure out the pattern - then make it
      # configurable
      if($provider_name eq 'twitter') {
        # get twitter account info
        my $response = $access_token -> get('https://api.twitter.com/1/users/show.json?user_id=' . $access_token->{user_id} . '&include_entities=true');
        if($response -> is_success) {
          my $json = JSON::decode_json($response -> decoded_content);
          use Data::Dumper ();
          #print STDERR "Returned from twitter:", Data::Dumper -> Dump([$json]);
          $info->{user_id} = $access_token -> {user_id};
          $info->{name} = $json->{name};
          $info->{url} = $json->{url};
          $info->{lang} = $json->{lang};
          $info->{description} = $json->{description};
          $info->{timezone} = $json->{time_zone};
          $info->{profile_img_url} = $json->{profile_image_url};
        }
      }
      elsif($provider_name eq 'google') {
        # get google account info
        # https://www.googleapis.com/oauth2/v1/userinfo?alt=json
        my $response = $access_token -> get('https://www.googleapis.com/oauth2/v1/userinfo?alt=json');
        if($response -> is_success) {
          my $json = JSON::decode_json($response -> decoded_content);
          $info->{user_id} = $json->{id};
          $info->{name} = $json->{name};
          $info->{url} = $json->{link};
          $info->{lang} = $json->{locale};
        }
      }
  
      if($info -> {user_id}) { # we can authenticate!
        my $user = $self -> user;
        my $oauth_id = $self -> model('DB::OauthIdentity') -> find({
          oauth_user_id => "".$info -> {user_id},
          oauth_service_id => $provider -> {id},
        });
        if($oauth_id) {
          $oauth_id -> update({
            token => $info->{token},
            token_secret => $info->{token_secret},
          });
          $user = $oauth_id -> user;
        }
        else {
          my $guard = $self -> model('DB') -> txn_scope_guard;
          if(!$user) {
            $user = $self -> model('DB::User') -> new({
              name => $info->{name},
              url => $info->{url},
              lang => $info->{lang},
              description => $info->{description},
              timezone => $info->{timezone},
            });
            $user -> insert;
            # if we now have only one user and no projects, themes, or boards,
            # then mark them as the first admin
            if($self -> model('DB::User') -> count == 1 &&
               $self -> model('DB::Project') -> count == 0 &&
               $self -> model('DB::Theme') -> count == 0 &&
               $self -> model('DB::Board') -> count == 0) {
              $user -> update({is_admin => 1});
            }
          }
          $oauth_id = $self -> model('DB::OauthIdentity') -> new({
            oauth_service_id => $provider -> {id},
            user_id => $user -> id,
            oauth_user_id => $info->{user_id},
            token => $info->{token},
            token_secret => $info->{token_secret},
            profile_img_url => $info->{profile_img_url},
          });
          $oauth_id -> insert;
          $guard -> commit;
        }
        $self -> user($user);
      }
      return 1;
    }
    else {
      $self -> session -> {allow_GET_for_oauth} = 1;
      $self->res->redirect( $client -> authorize_url(
        callback => $defaults{callback}
      ) );
      $self -> detach;
    }
  }
  
=method logout ()

=cut

  method logout { 
    $self -> _user(undef);
    delete $self -> session -> {user_id};
  }

}
