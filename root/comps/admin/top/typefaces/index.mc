% $.IndexTable(1) {{
%   $.IndexHead {{
      <% $.IndexHeadName("Typeface") %>
%   }}
%   $.IndexBody {{
%     for my $typeface (@{$c -> stash -> {typefaces}||[]}) {
%       $.IndexItem {{
%         $.IndexItemName("","/admin/typeface/".$typeface->id) {{
            <% $typeface->name %>
%         }}
%       }}
%     }
%   }}
% }}
<a href="<% $c->uri_for("/admin/typeface/new") %>" class="btn btn-primary">
  New Typeface
</a>
