<%args>
$.page
</%args>
<h1>Discard Page</h1>
% if($c->stash->{error_msg}) {
<p><% $c -> stash -> {error_msg} %></p>
% }
<p>
Are you sure you want to discard changes made to the "<% $.page->title | H %>"
page since the previous edition? Discarded changes will be lost forever.
</p>
<form method="POST">
  <input type="submit" value="Discard Changes" class="btn btn-primary" />
  or <a href="<% $c -> uri_for("/admin/project/".$.project_id."/page") %>">Cancel</a>.
</form>

