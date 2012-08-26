<h3>Configuration</h3>
<table class="table table-striped table-condensed">
  <tbody>
    <tr>
      <td>Name</td>
      <td><% $.board -> name %></td>
    </tr>
  </tbody>
</table>

<div class="actions">
  <a href="<% $c -> uri_for("/admin/board/" . $.board_id . "/edit") %>" class="btn btn-primary">Edit Configuration</a>
</div>
