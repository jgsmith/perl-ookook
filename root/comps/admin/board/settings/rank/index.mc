<%args>
$.ranks => sub { [] }
</%args>

% $.IndexTable {{
%   $.IndexHead {{
      <% $.IndexHeadName("Rank") %>
      <% $.IndexHeadActions("Modify") %>
%   }}
%   $.IndexBody {{
%     for my $rank (@{$.ranks}) {
%       $.IndexItem {{
%         $.IndexItemName("", "/admin/board/".$.board_id."/rank/".$rank->position . "/edit") {{
            <% $rank->name | H %>
%         }}
%         $.IndexItemActions {{
           <% $.IndexItemAction(
                !($rank->position > 0 && $rank->position < $#{$.ranks}),
                "/admin/board/".$.board_id."/rank/".$rank->position."/down",
                "arrow-down",
                ""
             ) %>
           <% $.IndexItemAction(
                !($rank->position > 0 && $rank->position <= $#{$.ranks}),
                "/admin/board/".$.board_id."/rank/".$rank->position."/up",
                "arrow-up",
                ""
             ) %>
           <% $.IndexItemAction(
                $rank->position == 0,
                "", 
                "minus-sign", 
                "Remove Rank"
              ) %>
%         }}
%       }}
%     }
%   }}
% }}
<a href="<% $c->uri_for("/admin/board/".$.board_id."/rank/new") %>" class="btn btn-primary">
  New Rank
</a>
