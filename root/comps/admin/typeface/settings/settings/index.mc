<h3>Configuration</h3>
<table class="table table-striped table-condensed">
  <tbody>
    <tr>
      <td>Name</td>
      <td><% $.theme -> name %></td>
    </tr>
    <tr>
      <td>Description</td>
      <td><% $.theme -> description %></td>
    </tr>
  </tbody>
</table>

<div class="actions">
  <a href="<% $c -> uri_for("/admin/theme/" . $.theme_id . "/edit") %>" class="btn btn-primary">Edit Configuration</a>
</div>
