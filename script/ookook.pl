#! /usr/bin/perl -w

use 5.012;
use feature qw(switch);

use LWP::UserAgent;
use HTTP::Request;
use JSON;
use YAML::Any;

my $server_base = "http://localhost:3000";
# get the server password from the conf/ookook_local.conf file
#
# <OokOok::Plugin::Authentication>
#   system_password ...
#   system_user_enabled 1
# </OokOok::Plugin::Authentication>
#
my $server_passwd;
open my $fh, "<", "conf/ookook_local.conf";
if($fh) {
  my @lines = map { (split(/\s+/))[-1] } grep { /system_password/ } (<$fh>);
  close $fh;
  $server_passwd = pop @lines;
}
    

my $ua = LWP::UserAgent -> new;

#
# will do things like create projects and themes, list them, etc.
#

# ookook.pl {list|create} {resource type}

sub edit {
    my($string) = @_;

    open my $fh, ">", "/tmp/ookook.edit.$$" or die "Unable to open temporary file for editing.\n";
    print $fh $string;
    close $fh;
    system($ENV{EDITOR}||'vi',"/tmp/ookook.edit.$$");
    open $fh, "<", "/tmp/ookook.edit.$$" or die "Unable to open temporary file to retrieve edited content.\n";
    local($/);
    my $content = <$fh>;
    close $fh;
    return $content;
}

sub OPTIONS {
  my($url) = @_;

  my $headers = HTTP::Headers -> new;
  $headers -> header(Accept => 'application/json');
  $headers -> header('Content-Type' => 'application/json');
  $headers -> header('X-OokOokSysAuth' => $server_passwd);
  my $req = HTTP::Request->new(OPTIONS => $url, $headers);
  my $res = $ua -> request($req);
  my %options;
  for my $o ($res -> header('Allow')) {
    $options{$o} = 1;
  }

  return \%options;
}
  

sub GET {
  my($url) = @_;

  my $headers = HTTP::Headers -> new;
  $headers -> header(Accept => 'application/json');
  $headers -> header('Content-Type' => 'application/json');
  $headers -> header('X-OokOokSysAuth' => $server_passwd);
  my $req = HTTP::Request->new(GET => $url, $headers);
  my $res = $ua -> request($req);
  if($res -> is_success) {
    return JSON::decode_json($res -> content);
  }
  else {
    print "Unable to retrieve resources: ", $res -> status_line, "\n";
  }
}

sub POST {
  my($url, $content) = @_;

  if(ref $content) {
    $content = JSON::encode_json($content);
  }

  my $headers = HTTP::Headers -> new;

  $headers -> header('Accept' => 'application/json');
  $headers -> header('Content-Type' => 'application/json');
  $headers -> header('X-OokOokSysAuth' => $server_passwd);

  my $req = HTTP::Request->new( POST => $url, $headers, $content );
  my $res = $ua -> request($req);

  if($res -> code < 300) {
    return JSON::decode_json($res -> content);
  }
  else {
    return +{
      error => $res -> status_line,
    };
  }
}

sub PUT {
  my($url, $content) = @_;

  if(ref $content) {
    $content = JSON::encode_json($content);
  }

  my $headers = HTTP::Headers -> new;

  $headers -> header('Accept' => 'application/json');
  $headers -> header('Content-Type' => 'application/json');
  $headers -> header('X-OokOokSysAuth' => $server_passwd);

  my $req = HTTP::Request->new( PUT => $url, $headers, $content );
  my $res = $ua -> request($req);

  if($res -> code < 300) {
    return JSON::decode_json($res -> content);
  }
  else {
    return +{
      error => $res -> status_line,
    };
  }
}

sub resource_collection_url {
  my($type) = @_;
 
  given($type) {
    when (qr/projects?/) { return $server_base."/project"; }
    when (qr/themes?/) { return $server_base."/theme"; }
    when (qr/boards?/) { return $server_base."/board"; }
    default { print STDERR "Bad resource type: $type"; return; }
  }
}

sub resource_url {
  my $url_base = shift;
  my $key;
  my $n;
  if(@_ > 1) {
    $key = shift;
  }
  $n = shift;

  my $json = GET($url_base);

  my %urls;
  if($key) {
    %urls = map { $_->{id} => $_->{_links}{self} } @{$json->{_embedded}->{$key}||[]};
  }
  else {
    %urls = map { $_->{id} => $_->{_links}{self} } @{$json->{_embedded}||[]};
  }

  my @ids = sort keys %urls;
  if($url_base =~ m{/page-part}) {
    if($urls{$n}) {
      return $urls{$n};
    }
    elsif($n =~ m{^\d+$} && $n < @ids) {
      return $urls{$ids[$n-1]};
    }
    else {
      return $url_base . "/" . $n;
    }
  }
  if($n !~ m{^[-A-Za-z0-9_]{20}$}) {
    $n = $ids[$n-1];
  }
  
  return $urls{$n};
}

sub do_list {
  my($url_base, $json, @rest) = build_url(@_);
  return unless $url_base;

  if($url_base =~ m{/edition$}) {
    return do_list_editions($url_base);
  }

  my %items;
  for my $i (@{$json->{_embedded}||[]}) {
    $items{$i->{id}} = $i;
  }
  my $count = 1;
  for my $id (sort keys %items) {
    print $count . ") $id: " . ($items{$id}->{name}||$items{$id}->{title}) . "\n";
    $count += 1;
  }
  if($count == 1) {
    print "No resources returned.\n";
  }
}

sub do_list_editions {
  my($url_base) = @_;

  if($url_base !~ m{/edition}) {
    $url_base .= "/edition";
  }
  my $json = GET($url_base);
  if($json->{error}) {
    print STDERR "Unable to retrieve editions: ", $json->{error}, "\n";
    return;
  }
  my @closings = sort grep { defined && $_ ne "" } map { $_ -> {closed_on} } @{$json->{_embedded}||[]};
  if(@closings) {
    my $count = 1;
    for my $t (@closings) {
      print $count . ") $t\n";
      $count += 1;
    }
  }
  else {
    print "No published editions\n";
  }
}

sub build_url {
  my $type = shift;
  my $url_base = resource_collection_url($type);

  return unless $url_base;

  my $json = GET($url_base);
  while(@_) {
    my $n = shift;
    $n = resource_url($url_base, $n);
    return unless $n;
    $url_base = $n;
    if(@_) {
      $type = shift;
      $url_base .= "/$type";
      $json = GET($url_base);
    }
  }


  if($json -> {error}) {
    print STDERR "Unable to retrieve resource schema: ", $json->{error}, "\n";
    return;
  }

  return $url_base, $json, @_;
}

sub do_create {
  my($url_base, $schema, @rest) = build_url(@_);
  return unless $url_base;

  if(!OPTIONS($url_base)->{POST}) {
    print STDERR "Unable to create resource\n";
  }

  if($url_base =~ m{/edition$}) {
    # we're just POSTing to create an edition
    POST($url_base, {});
    return do_list_editions($url_base);
  }

  if($url_base =~ m{/page-part$}) {
    print STDERR "You must provide a name for the page part\n";
    return;
  }

  # this gets us the schema
  my $data = {};
  for my $prop (keys %{$schema->{_schema}{properties}}) {
    my $info = $schema->{_schema}{properties}{$prop};
    next if $info->{is} && $info->{is} eq 'ro';
    next if $info->{valueType} && $info->{valueType} eq 'link';
    $data->{$prop} = "___";
  }
  # now we want to put this up for editing - and wait for the file to be edited
  my $file = YAML::Any::Dump($data);
  $file = edit($file);
  $data = YAML::Any::Load($file);

  for my $p (keys %$data) {
    delete $data->{$p} if $data->{$p} eq "___";
  }

  if(0 < keys %$data) {
    POST( $url_base, $data );
  }

  do_list(@_);
}

sub do_edit {
  my($url_base, $schema, @rest) = build_url(@_);
  return unless $url_base;

  if(!OPTIONS($url_base)->{PUT}) {
    print STDERR "Unable to edit resource\n";
  }

  my $json = GET($url_base);

  my $data = {};
  for my $prop (keys %{$schema->{_schema}{properties}}) {
    my $info = $schema->{_schema}{properties}{$prop};
    next if $info -> {is} && $info->{is} eq 'ro';
    next if $info->{valueType} && $info->{valueType} eq 'link';
    $data->{$prop} = $json->{$prop};
  }

  my $file = YAML::Any::Dump($data);
  my $newFile = edit($file);
  if($newFile eq $file) {
    print STDERR "No changes made\n";
    return;
  }
  my $newData = YAML::Any::Load($newFile);
  for my $p (keys %$newData) {
    delete $newData->{$p} if $newData->{$p} eq $data->{$p};
  }
  if(0 < keys %$newData) {
    PUT( $url_base, $newData );
  }

  do_detail(@_);
}

sub do_detail {
  my($url_base, $schema, @rest) = build_url(@_);
  return unless $url_base;

  my $json = GET($url_base);
  if($json -> {error}) {
    print STDERR "Unable to retrieve resource: ", $json->{error}, "\n";
  }
  print YAML::Any::Dump($json);
}

my $cmd = shift @ARGV;
given($cmd) {
  when ('list') { do_list(@ARGV) }
  when ('create') { do_create(@ARGV) }
  when ('detail') { do_detail(@ARGV) }
  when ('edit') { do_edit(@ARGV) }
  default { print STDERR "Unknown command: $cmd\n"; }
}
