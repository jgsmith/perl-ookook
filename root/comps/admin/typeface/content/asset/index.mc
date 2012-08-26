<%args>
$.assets => sub { [] }
</%args>

% $.IndexTable {{
%   $.IndexHead {{
      <% $.IndexHeadName("Asset") %>
      <% $.IndexHeadCol("type", "Type") %>
      <% $.IndexHeadStatus("Status") %>
      <% $.IndexHeadActions("Modify") %>
%   }}
%   $.IndexBody {{
%     for my $asset (@{$.assets}) {
%       my $asset_id = $asset->id;
%       $.IndexItem {{
%         $.IndexItemName("image", "/admin/theme/".$.theme_id."/asset/$asset_id/edit") {{
            <% $asset->name | H %>
%         }}
%         $.IndexItemCol("type") {{
            <% $asset -> type | H %>
%         }}
%         $.IndexItemStatus {{
%           if($asset->source_version->edition->is_closed) {
              Published
%           }
%           else {
              Modified
%           }
%         }}
%         $.IndexItemActions {{
           <% $.IndexItemAction(
                $asset->source_version->edition->is_closed,
                "", 
                "minus-sign", 
                "Discard Changes"
              ) %>
%         }}
%       }}
%     }
%   }}
% }}
<a href="<% $c->uri_for("/admin/theme/".$.theme_id."/asset/new") %>" class="btn btn-primary">
  <i class="icon-white icon-arrow-up"></i> Upload Asset
</a>
