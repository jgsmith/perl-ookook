package OokOok::Plugin::Authentication;

use Moose;

use namespace::autoclean;

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
    my $passwd = $c -> config -> {'OokOok::Plugin::Authentication'}->{system_password};

    if($c -> session -> {user_id}) {
      return $c -> model('DB::User') -> find({ id => $c -> session -> {user_id} });
    }
    elsif(defined($header) && defined($passwd) && $header eq $passwd && $c -> config -> {'OokOok::Plugin::Authentication'}->{system_user_enabled}) {
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

sub user {
  my $c = shift;

  if(@_) {
    $c -> _user($_[0]);
    if(defined $_[0]) {
      $c -> session -> {user_id} = $_[0] -> id;
    }
    else {
      delete $c -> session -> {user_id};
    }
  }
  $c -> _user;
}

sub authenticate {
  my($c, $provider_name) = @_;

  my $provider = $c -> config -> {'OokOok::Plugin::Authentication'} -> {providers} -> {$provider_name};
  return unless $provider;

  my($consumer_key, $consumer_secret) = 
    @{$provider}{qw/consumer_key consumer_secret/};

  my %defaults = (
    site => $provider -> {site},
    request_token_path => $provider -> {request_token_path},
    access_token_path => $provider -> {access_token_path},
    authorize_path => $provider -> {authorize_path},
    callback => $c -> uri_for( 
      $c -> action, 
      $c -> req -> captures, 
      @{ $c -> req -> args } 
    )->as_string,
    session => sub { 
      if(@_ == 1) { $c -> session -> {$_[0]} }
      else { $c -> session(@_) }
    },
  );

  my $client = Net::OAuth::Client->new(
    $consumer_key, $consumer_secret,
    %defaults,
  );

  my $oauth_token = $c -> req -> method eq 'GET'
     ? $c -> req -> query_params -> {oauth_token}
     : $c -> req -> body_params -> {oauth_token};
  my $oauth_verifier = $c -> req -> method eq 'GET'
     ? $c -> req -> query_params -> {oauth_verifier}
     : $c -> req -> body_params -> {oauth_verifier};

  if($oauth_token) {
    my $access_token = $client -> get_access_token(
         $oauth_token, $oauth_verifier
    );

    # clean up session
    delete $c -> session -> {$oauth_token};

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
        $info->{user_id} = $access_token -> {user_id};
        $info->{name} = $json->{name};
        $info->{url} = $json->{url};
        $info->{lang} = $json->{lang};
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
      my $user = $c -> user;
      my $oauth_id = $c -> model('DB::OauthIdentity') -> find({
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
        if(!$user) {
          $user = $c -> model('DB::User') -> new({
            name => $info->{name},
            url => $info->{url},
            lang => $info->{lang},
          });
          $user -> insert;
        }
        $oauth_id = $c -> model('DB::OauthIdentity') -> new({
          oauth_service_id => $provider -> {id},
          user_id => $user -> id,
          oauth_user_id => $info->{user_id},
          token => $info->{token},
          token_secret => $info->{token_secret},
        });
        $oauth_id -> insert;
      }
      $c -> user($user);
    }
    return 1;
  }
  else {
    $c->res->redirect( $client -> authorize_url(
      callback => $defaults{callback}
    ) );
    $c -> detach;
  }
}

sub logout {
  my($c) = @_;

  $c -> user(undef);
}

1;
