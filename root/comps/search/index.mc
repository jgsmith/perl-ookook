<%args>
$.results = sub { +{} }
$.q
$.hits = 0
$.docs = sub { [] }
</%args>
<h1>Search</h1>
<form>
  <input type="text" name="q" value="<% $.q | H %>">
</form>
% if( defined($.q) || $.hits ) {
%   if( $.hits ) {
<p>We have <% $.hits %> hit<% $.hits == 1 ? '' : 's' %>.</p>
%     for my $docset (@{$.docs}) {
<p><h3>
%       if($docset -> {type} eq 'page') {
  <% $docset -> {instances}->[0]->{doc} -> project -> name | H %>:
      <% $docset->{instances}->[0]->{doc}->title | H %>
%       }
%       elsif($docset -> {type} eq 'project') {
  <% $docset->{instances}->[0]->{doc}->name | H %> (project)
%       }
  (<% scalar(@{$docset->{instances}}) %>)
  </h3>
  <p>Score: <% $docset->{score} | H %> (<% $docset->{date} | H %>)</p>
% if(@{$docset -> {instances} -> [0] -> {highlights}||[]}) {
    <p><% join("</p><p>", @{$docset -> {instances} -> [0] ->{highlights}}) %></p>
% }
% if(@{$docset->{instances}} > 1) {
<p>Other versions: 
%   for my $i (1..@{$docset->{instances}}-1) {
  <% $docset->{instances}->[$i]->{date} %>
  (<% $docset->{instances}->[$i]->{score} %>)
%   }
% }
%     }
%   }
%   elsif(defined($.q)) {
<p>No results found.</p>
%   }
% }
<pre><% Data::Dumper -> Dump([$.results]) | H %></pre>
