<%args>
$.form_data => sub { +{} }
</%args>

<%method form($title, $button)>
<form method="POST" class="well form-horizontal" enctype="multipart/form-data">
  <fieldset>
    <legend><% $title %></legend>
    <div class="control-group offset1 span11<% $.formClasses('name') %>">
      <input type="text" name="name" class="span12" placeholder="Asset name..." id="asset_name" value="<% $.form_data->{name} | H %>">
      <input type="file" name="raw" class="span12" placeholder="Asset content..." />
    </div>
  </fieldset>
  <div class="form-actions">
    <input accesskey="S" class="btn btn-primary" name="commit" type="submit" value="<% $button %>">
    or <a href="<% $c -> uri_for("/admin/theme/" . $.theme_id . "/asset") %>">Cancel</a>
  </div>
</form>
</%method>
