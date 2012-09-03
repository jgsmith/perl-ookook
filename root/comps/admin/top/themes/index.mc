<div class="span12">
% $.IndexTable(1) {{
%   $.IndexHead {{
      <% $.IndexHeadName("Theme") %>
%   }}
%   $.IndexBody {{
%     for my $theme (@{$c -> stash -> {themes}||[]}) {
%       $.IndexItem {{
%         $.IndexItemName("","/admin/theme/".$theme->id) {{
            <% $theme->name %>
%         }}
%       }}
%     }
%   }}
% }}
<a href="<% $c->uri_for("/admin/theme/new") %>" class="btn btn-primary">
  New Theme
</a>
</div>
