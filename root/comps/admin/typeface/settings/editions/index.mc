<%args>
$.editions => sub { [] }
</%args>

% $.IndexTable {{
%   $.IndexHead {{
      <% $.IndexHeadName("Edition") %>
      <% $.IndexHeadStatus("Published At") %>
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
%       }}
%     }
%   }}
% }}
<a href="<% $c->uri_for("/admin/theme/".$.theme_id."/editions/new") %>" class="btn btn-primary">
  New Edition
</a>
