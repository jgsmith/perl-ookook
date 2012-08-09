<h3>Configuration</h3>
<table class="table table-striped table-condensed">
  <tbody>
    <tr>
      <td>Name</td>
      <td colspan="2"><% $.project -> name %></td>
    </tr>
    <tr>
      <td>Description</td>
      <td colspan="2"><% $.project -> description %></td>
    </tr>
    <tr>
      <td>Theme</td>
      <td>
        <% $.project->theme->name %>
        (<% $.project->theme_date %>)
      </td>
      <td>
        <form class="form-inline" method="POST" action="<% $c -> uri_for("/admin/project/". $.project_id . "/settings/edit") %>">
          <input type="hidden" name="update_theme_date" value="1" />
          <button type="submit" name="commit" class="btn">Use Current Theme Edition</button>
        </form>
      </td>
    </tr>
  </tbody>
</table>

<div class="actions">
  <a href="<% $c -> uri_for("/admin/project/" . $.project_id . "/settings/edit") %>" class="btn btn-primary">Edit Configuration</a>
</div>
