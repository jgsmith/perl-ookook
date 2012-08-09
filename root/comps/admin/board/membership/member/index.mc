<%args>
$.board_members => sub { [] }
$.ranks => sub { +{} }
</%args>

% $.IndexTable {{
%   $.IndexHead {{
      <% $.IndexHeadName("Member") %>
      <% $.IndexHeadStatus("Rank") %>
      <% $.IndexHeadActions("Modify") %>
%   }}
%   $.IndexBody {{
%     for my $member (@{$.board_members}) {
%       my $member_id = $member->user->id;
%       $.IndexItem {{
%         $.IndexItemName("", "") {{
            <% $member->user->name | H %>
%         }}
%         $.IndexItemStatus {{
              <% $.ranks -> {$member -> rank} -> name %>
%         }}
%         $.IndexItemActions {{
           <!-- % $.IndexItemAction(
                $layout->source_version->edition->is_closed,
                "", 
                "minus-sign", 
                "Discard Changes"
              ) % -->
%         }}
%       }}
%     }
%   }}
% }}
