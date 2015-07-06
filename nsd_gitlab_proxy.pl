#!/usr/bin/perl

use strict;

my $version = "2.1";

if ($#ARGV < 2) {
  my $message = <<"END_MESSAGE";
  Usage: nsd_gitlab_proxy.pl nsd_user nsd_password port
  git config --global http.http://owa.nsd.ru.proxy localhost:<port>
  git remote add origin http://owa.nsd.ru/gitlab/<path_to>/<your_repository>.git
END_MESSAGE

  die $message;
}

open STDOUT, '>', "./nsd_gitlab_proxy.out";
open STDERR, '>', "./nsd_gitlab_proxy.err";

print "owa_proxy $version\n";

my $nsd_user = $ARGV[0];
my $nsd_password = $ARGV[1];
my $port = $ARGV[2];

use WWW::Mechanize;
use MIME::Base64;
use Encode::Byte;

my $mech = WWW::Mechanize->new(cookie_jar => {}, autocheck => 0, agent => "Mozilla/5.0");
$mech->stack_depth(0);

$mech->add_handler("request_send", sub { shift->dump; return });
$mech->add_handler("response_done", sub { shift->dump; return });

use HTTP::Daemon;

my $d = HTTP::Daemon->new(
  LocalPort => $port
) || die;


while (my $connection = $d->accept) {
  $mech->get("https://owa.nsd.ru/CookieAuth.dll?GetLogon?curl=Z2FgitlabZ2F&reason=0&formdir=3");

  if ($mech->form_id("logonForm")) 
  {
    $mech->submit_form(
      form_id => "logonForm",
      fields => {
        "username" => $nsd_user,
        "password" => $nsd_password
      }
    );
  }

  my $request = $connection->get_request();
    
  $request->uri->scheme("https");

  print $connection->sockhost . ": " . $request->uri->as_string . "\n";
  
  #my $response = $mech->get($request->uri->as_string);
  #my $response = $mech->simple_request($request);
  $request->header("User-agent", "Mozilla/5.0");
  $request->header("Authorization", "Basic ".encode_base64("$nsd_user:$nsd_password"));
  #$request->header("Accept-Encoding", "identity");
  $request->header("Connection", "close");
  $request->header("Proxy-Connection", "close");

  $mech->prepare_request($request);
  
  my $firstTime = 1;
  $mech->request($request, sub {
    my ($data, $response) = @_;
  
    if ($firstTime) {
      $firstTime = 0;
      $connection->send_response($response); 
    }
    
    print $connection $data;
    
    if (!$data) {
      $connection->close();
      undef($connection);
    }
  });
}

1;

