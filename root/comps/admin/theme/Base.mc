<%args>
$.theme
</%args>

<%shared>
$.theme_id => sub { shift -> theme -> id }
</%shared>

<%augment nav_tabs>
  <% $.navLink("/admin/theme/" .$.theme_id."/layout", "Design", "/admin/theme/content") %>
  <% $.navLink("/admin/theme/" .$.theme_id."/settings", "Settings", "/admin/theme/settings") %>
</%augment>

