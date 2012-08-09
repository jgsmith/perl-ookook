<%args>
$.styles => sub { [] }
</%args>

% $.IndexTable {{
%   $.IndexHead {{
      <% $.IndexHeadName("Style") %>
      <% $.IndexHeadStatus("Status") %>
      <% $.IndexHeadActions("Modify") %>
%   }}
%   $.IndexBody {{
%     for my $style (@{$.styles}) {
%       my $style_id = $style->id;
%       $.IndexItem {{
%         $.IndexItemName("stylesheet", "/admin/theme/".$.theme_id."/style/$style_id/edit") {{
            <% $style->name | H %>
%         }}
%         $.IndexItemStatus {{
%           if($style->source_version->edition->is_closed) {
              Published
%           }
%           else {
              Modified
%           }
%         }}
%         $.IndexItemActions {{
           <% $.IndexItemAction(
                $style->source_version->edition->is_closed,
                "", 
                "minus-sign", 
                "Discard Changes"
              ) %>
%         }}
%       }}
%     }
%   }}
% }}
<a href="<% $c->uri_for("/admin/theme/".$.theme_id."/style/new") %>" class="btn btn-primary">
  New Style
</a>
