<h1>New Project Edition</h1>
<p>
Are you sure you want to publish a new edition of this project? Any changes
you have made will be published immediately and can not be changed.
</p>
<form method="POST">
  <input type="submit" value="Publish Project Edition Immediately" class="btn btn-primary" />
  or <a href="<% $c->uri_for("/admin/project/" . $.project_id . "/editions") %>">Cancel</a>.
</form>
