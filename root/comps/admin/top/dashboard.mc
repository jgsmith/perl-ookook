<%args>
$.projects => sub { [] }
$.boards   => sub { [] }
$.themes   => sub { [] }
</%args>
% if(@{$.themes} == 0 && $c->user->is_admin) {
<div class="hero-unit" style="text-align: center;">
  <p>You don't have any themes!</p>
  <div class="offset4 span4">
    <a href="<% $c->uri_for("/admin/theme/new") %>" class="btn btn-primary btn-large">Create Your First Theme</a>
  </div>
</div>
% }
% elsif(@{$.projects} == 0) {
<div class="hero-unit" style="text-align: center;">
  <p>You don't have any projects!</p>
  <div class="offset4 span4">
    <a href="<% $c->uri_for("/admin/project/new") %>" class="btn btn-primary btn-large">Create Your First Project</a>
  </div>
</div>
% }
% else {
<div class="row-fluid">
  <div class="span6">
% $.IndexTable(1) {{
%   $.IndexHead {{
  <th class="name" style="width: 100%">
<a href="<% $c->uri_for("/admin/project/new") %>" class="btn btn-primary"
   style="float: right">
  New Project
</a>
  Project
  </th>
%   }}
%   $.IndexBody {{
%     for my $project (@{$.projects}) {
%       $.IndexItem {{
%         $.IndexItemName("","/admin/project/".$project->id) {{
            <% $project->name %>
%         }}
%       }}
%     }
%   }}
% }}

% $.IndexTable(1) {{
%   $.IndexHead {{
      <% $.IndexHeadName("Board") %>
%   }}
%   $.IndexBody {{
%     for my $board (@{$.boards}) {
%       $.IndexItem {{
%         $.IndexItemName("","/admin/board/".$board->id) {{
            <% $board->name %>
%         }}
%       }}
%     }
%   }}
% }}
</div><div class="span6">
% if($c -> user -> is_admin) {
% $.IndexTable(1) {{
  <th class="name" style="width: 100%">
<a href="<% $c->uri_for("/admin/theme/new") %>" class="btn btn-primary"
   style="float: right">
  New Theme
</a>
  Theme
  </th>

%   $.IndexBody {{
%     for my $theme (@{$.themes}) {
%       $.IndexItem {{
%         $.IndexItemName("","/admin/theme/".$theme->id) {{
            <% $theme->name %>
%         }}
%       }}
%     }
%   }}
% }}

% }
</div>
</div>
</div>
% }
