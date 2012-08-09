<%args>
$.form_data => sub { +{} }
</%args>

<%method form($title, $button)>
<form method="POST" class="well form-horizontal">
  <fieldset>
    <legend><% $title %></legend>
    <div class="control-group offset1 span11<% $.formClasses('name') %>">
      <input type="text" name="name" class="span12" placeholder="Snippet name..." id="style_name" value="<% $.form_data->{name} | H %>">
    </div>
    <div class="control-group offset1 span11<% $.formClasses('content') %>">
      <textarea class="span12 large" id="style_styles" placeholder="Snippet content..." name="content"><% $.form_data->{content} | H %></textarea>
    </div>
  </fieldset>
  <div class="form-actions">
    <input accesskey="S" class="btn btn-primary" name="commit" type="submit" value="<% $button %>">
    or <a href="<% $c -> uri_for("/admin/project/" . $.project_id . "/snippet") %>">Cancel</a>
  </div>
</form>
</%method>
