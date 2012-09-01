<%args>
$.layouts => sub { [] }
</%args>

% $.IndexTable {{
%   $.IndexHead {{
      <% $.IndexHeadName("Layout") %>
      <% $.IndexHeadStatus("Status") %>
      <% $.IndexHeadActions("Modify") %>
%   }}
%   $.IndexBody {{
%     for my $layout (@{$.layouts}) {
%       my $layout_id = $layout->id;
%       $.IndexItem {{
%         $.IndexItemName("layout", "/admin/theme/".$.theme_id."/layout/$layout_id/edit") {{
            <% $layout->name | H %>
%         }}
%         $.IndexItemStatus {{
%           if($layout->source_version->edition->is_closed) {
              Published
%           }
%           else {
              Modified
%           }
%         }}
%         $.IndexItemActions {{
           <% $.IndexItemAction(
                $layout->source_version->edition->is_closed,
                "", 
                "minus-sign", 
                "Discard Changes"
              ) %>
           <% $.IndexItemTargetedAction(
                0,
                "/admin/theme/".$.theme_id."/layout/$layout_id/preview", 
                "screenshot", 
                "Preview",
                "_" . $layout_id
              ) %>
%         }}
%       }}
%     }
%   }}
% }}
<a href="<% $c->uri_for("/admin/theme/".$.theme_id."/layout/new") %>" class="btn btn-primary">
  New Layout
</a>
