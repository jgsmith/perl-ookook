<%augment wrap><!DOCTYPE html>
<html lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=2.0">
    <title>OokOok</title>
    <script src="<% $c->uri_for('/static/js/jquery.js') %>"></script>
    <script src="<% $c->uri_for('/static/js/bootstrap.min.js') %>"></script>
    <script src="<% $c->uri_for('/static/js/ace/ace.js') %>"></script>
    <script src="<% $c->uri_for('/static/js/ace/mode-xml.js') %>"></script>
    <link href="<% $c->uri_for('/static/css/bootstrap.min.css') %>" rel="stylesheet">
    <link href="<% $c->uri_for('/static/css/bootstrap-responsive.css') %>" rel="stylesheet">
    <link href="<% $c->uri_for('/static/css/overrides.css') %>" rel="stylesheet">
    <style>
      body {
        padding-top: 60px;
      }
    </style>
  </head>
  <body>
    <div class="navbar navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container">
          <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </a>
          <a class="brand" href="<% $c->uri_for("/") %>">OokOok</a>
          <div class="nav-collapse">
            <ul class="nav">
              <% $.navLink("/", "Home") %>
%             if($c -> user) {
                <% $.navLink("/admin", "Admin") %>
%             }
            </ul>
            <ul class="nav pull-right">
%             if($c -> user) {
                <li><a href="<% $c->uri_for("/admin/preferences") %>">
                  Logged in as <% $c->user->name %>
                </a></li>
                <li><form class="form-inline" method="POST" 
                      style="margin: 0px;"
                      action="<% $c->uri_for("/admin/oauth/logout") %>">
                      <button type="submit" class="btn">Logout</button>
                    </form>
                </li>
%             } else
%             {
                <li><form class="form-inline" method="POST" 
                      style="margin: 0px;"
                      action="<% $c->uri_for("/admin/oauth/twitter") %>">
                      <button type="submit" class="btn">Login with Twitter</button>
                    </form>
                </li>
%             }
            </ul>
          </div>
        </div>
      </div>
    </div>

    <div class="container-fluid">
      <% inner() %>
    </div>
  </body>
</html>
</%augment>
<%method navLink($url, $text, $comp_path)>
% my $uri = $c -> uri_for($url);
% my $requri = substr($c -> request -> uri, 0, length($uri)+1);
% $comp_path ||= "/xxx";
% my $path = substr($m -> request_path, 0, length($comp_path)+1);
% if($requri eq $uri || $requri eq $uri."/" || $path eq $comp_path || $path eq $comp_path."/") {
<li class="active">
% }
% else {
<li>
% }
<a href="<% $uri %>"><% $text %></a>
</li>
</%method>
