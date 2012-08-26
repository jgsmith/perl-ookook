<%args>
$.theme_variables => sub { [] }
</%args>

% $.IndexTable {{
%   $.IndexHead {{
      <% $.IndexHeadName("Variable") %>
      <% $.IndexHeadStatus("Type") %>
      <% $.IndexHeadStatus("Default") %>
      <% $.IndexHeadStatus("Status") %>
      <% $.IndexHeadActions("Modify") %>
%   }}
%   $.IndexBody {{
%     for my $var (@{$.theme_variables}) {
%       my $var_id = $var->id;
%       $.IndexItem {{
%         $.IndexItemName("var", "/admin/theme/".$.theme_id."/variable/$var_id/edit") {{
            <% $var->name | H %>
%         }}
%         $.IndexItemStatus {{
            <% $var -> source_version -> type %>
%         }}
%         $.IndexItemStatus {{
            <% $var -> source_version -> default_value %>
%         }}
%         $.IndexItemStatus {{
%           if($var->source_version->edition->is_closed) {
              Published
%           }
%           else {
              Modified
%           }
%         }}
%         $.IndexItemActions {{
           <% $.IndexItemAction(
                $var->source_version->edition->is_closed,
                "", 
                "minus-sign", 
                "Discard Changes"
              ) %>
%         }}
%       }}
%     }
%   }}
% }}
<a href="<% $c->uri_for("/admin/theme/".$.theme_id."/variable/new") %>" class="btn btn-primary">
  New Variable
</a>
