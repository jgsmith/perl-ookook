<%args>
$.results = sub { +{} }
$.q
$.hits = 0
$.docs = sub { [] }
</%args>
<%method relativeDate($date)>
% my $dur = ($date - DateTime->now())->inverse;
% if($dur -> years > 1) {
    <% $dur -> years %> years ago
% }
% elsif($dur -> years == 1) {
    a year ago
% }
% elsif($dur -> months > 1) {
    <% $dur -> months %> months ago
% }
% elsif($dur -> months == 1) {
    a month ago
% }
% elsif($dur -> weeks > 1) {
    <% $dur -> weeks %> weeks ago
% }
% elsif($dur -> weeks == 1) {
    a week ago
% }
% elsif($dur -> days > 1) {
    <% $dur -> days %> days ago
% }
% elsif($dur -> days == 1) {
    yesterday
% }
% elsif($dur -> hours > 1) {
    <% $dur -> hours %> hours ago
% }
% elsif($dur -> hours == 1) {
    an hour ago
% }
% elsif($dur -> minutes > 1) {
    <% $dur -> minutes %> minutes ago
% }
% elsif($dur -> minutes == 1) {
    a minute ago
% }
% else {
    less than a minute ago
% }
</%method>
<h1>Search</h1>
<form>
  <input type="text" name="q" value="<% $.q | H %>">
</form>
<div class="search-results">
% if( defined($.q) || $.hits ) {
%   if( $.hits ) {
<p>We have <% $.hits %> hit<% $.hits == 1 ? '' : 's' %>.</p>
%     for my $docset (@{$.docs}) {
<div class="search-result">
<p><h3>
  <a href="<% $docset->{instances}->[0]->{link} | H %>">
%       if($docset -> {type} eq 'page') {
  <% $docset -> {instances}->[0]->{doc} -> project -> name | H %>:
      <% $docset->{instances}->[0]->{doc}->title | H %>
%       }
%       elsif($docset -> {type} eq 'project') {
  <% $docset->{instances}->[0]->{doc}->name | H %> (project)
%       }
  </a>
% if(@{$docset->{instances}} > 1) {
  (<% scalar(@{$docset->{instances}}) %>)
% }
  </h3>
% if(@{$docset -> {instances} -> [0] -> {highlights}||[]}) {
    <p><% join(" &hellip; ", @{$docset -> {instances} -> [0] ->{highlights}}) %></p>
% }
% if( $docset->{score} < 1 ) {
  <p class="meta">Score: <% $docset->{score} | H %> (<% $.relativeDate($docset->{date}) | Trim %>)</p>
% }
% if(@{$docset->{instances}} > 1) {
<p class="meta">Other versions: 
%   for my $i (1..@{$docset->{instances}}-1) {
  <% $.relativeDate($docset->{instances}->[$i]->{date}) | Trim %>
  (<% $docset->{instances}->[$i]->{score} %>)
%   }
% }
</div>
%     }
%   }
%   elsif(defined($.q)) {
<p>No results found.</p>
%   }
% }
% # <pre><% Data::Dumper -> Dump([$.results]) | H %></pre>
</div>
