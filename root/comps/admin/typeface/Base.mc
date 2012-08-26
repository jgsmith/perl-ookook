<%args>
$.typeface
</%args>

<%shared>
$.typeface_id => sub { shift -> typeface -> id }
</%shared>

<%augment nav_tabs>
  <% $.navLink("/admin/typeface/" .$.typeface_id."/layout", "Design", "/admin/typeface/content") %>
  <% $.navLink("/admin/typeface/" .$.typeface_id."/settings", "Settings", "/admin/typeface/settings") %>
</%augment>
<%method branding>
  <a class="brand" href="#"><% $.typeface->name %> Typeface</a>
</%method>
