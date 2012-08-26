<%args>
$.snippets => sub { [] }
</%args>

% $.IndexTable {{
%   $.IndexHead {{
      <% $.IndexHeadName("Snippet") %>
      <% $.IndexHeadStatus("Status") %>
      <% $.IndexHeadActions("Modify") %>
%   }}
%   $.IndexBody {{
%     for my $snippet (@{$.snippets}) {
%       my $snippet_id = $snippet->id;
%       $.IndexItem {{
%         $.IndexItemName("snippet", "/admin/project/".$.project_id."/snippet/$snippet_id/edit") {{
            <% $snippet->name | H %>
%         }}
%         $.IndexItemStatus {{
%           if($snippet->source_version->edition->is_closed) {
              Published
%           }
%           else {
              Modified
%           }
%         }}
%         $.IndexItemActions {{
           <% $.IndexItemAction(
                $snippet->source_version->edition->is_closed,
                "/admin/project/".$.project_id."/snippet/$snippet_id/discard", 
                "minus-sign", 
                "Discard Changes"
              ) %>
%         }}
%       }}
%     }
%   }}
% }}
<a href="<% $c->uri_for("/admin/project/".$.project_id."/snippet/new") %>" class="btn btn-primary">
  New Snippet
</a>
