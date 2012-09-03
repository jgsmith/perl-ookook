<div class="span12">
% $.IndexTable(1) {{
%   $.IndexHead {{
      <% $.IndexHeadName("Board") %>
%   }}
%   $.IndexBody {{
%     for my $board (@{$c -> stash -> {boards}||[]}) {
%       $.IndexItem {{
%         $.IndexItemName("","/admin/board/".$board->id) {{
            <% $board->name %>
%         }}
%       }}
%     }
%   }}
% }}
</div>
