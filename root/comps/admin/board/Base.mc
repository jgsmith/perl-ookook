<%args>
$.board
</%args>

<%shared>
$.board_id => sub { shift -> board -> id }
</%shared>

<%augment nav_tabs>
  <% $.navLink("/admin/board/".$.board_id."/member", "Membership", "/admin/board/membership") %>
  <% $.navLink("/admin/board/".$.board_id."/settings", "Settings", "/admin/board/settings") %>
</%augment>
<%method branding><% $.board->name %> Board</%method>

<%augment wrap>
  <div class="span12">
    <% inner() %>
  </div>
</%augment>
