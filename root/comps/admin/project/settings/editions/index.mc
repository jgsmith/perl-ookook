<%args>
$.editions => sub { [] }
</%args>

% $.IndexTable {{
%   $.IndexHead {{
      <% $.IndexHeadName("Edition") %>
      <% $.IndexHeadStatus("Published At") %>
      <% $.IndexHeadActions("Methods") %>
%   }}
%   $.IndexBody {{
%     for my $edition (reverse @{$.editions}) {
%       $.IndexItem {{
%         $.IndexItemName("", "") {{
            <% $edition->name | H %>
%         }}
%         $.IndexItemStatus {{
%           if($edition -> closed_on) {
              <% $edition -> closed_on %>
%           }
%           else {
              &mdash;
%           }
%         }}
%         $.IndexItemActions {{
%           $.IndexItemAction(
%              !$edition -> source -> is_closed,
%              "/admin/project/".$.project_id."/editions/".$edition->closed_on."/archive",
%              "download",
%              "Download"
%           )
%         }}
%       }}
%     }
%   }}
% }}
<a href="<% $c->uri_for("/admin/project/".$.project_id."/editions/new") %>" class="btn btn-primary">
  New Edition
</a>
