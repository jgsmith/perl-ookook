<%args>
$.project
</%args>

<%shared>
$.project_id => sub { shift -> project -> id }
</%shared>

<%augment nav_tabs>
  <% $.navLink("/admin/project/".$.project_id."/page", "Content", "/admin/project/content") %>
  <% $.navLink("/admin/project/".$.project_id."/settings", "Settings", "/admin/project/settings") %>
</%augment>
<%method branding><% $.project->name %> Project</%method>

<%augment wrap>
  <div class="span12">
    <% inner() %>
  </div>
</%augment>
