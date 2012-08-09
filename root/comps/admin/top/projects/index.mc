% $.IndexTable(1) {{
%   $.IndexHead {{
      <% $.IndexHeadName("Project") %>
%   }}
%   $.IndexBody {{
%     for my $project (@{$c -> stash -> {projects}||[]}) {
%       $.IndexItem {{
%         $.IndexItemName("","/admin/project/".$project->id) {{
            <% $project->name %>
%         }}
%       }}
%     }
%   }}
% }}
<a href="<% $c->uri_for("/admin/project/new") %>" class="btn btn-large btn-primary">
  New Project
</a>
