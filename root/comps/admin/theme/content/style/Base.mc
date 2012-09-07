<%args>
$.form_data => sub { +{} }
</%args>

<%method form($title, $button)>
<form method="POST" class="well form-horizontal">
  <fieldset>
    <legend><% $title %></legend>
    <div class="control-group offset1 span11<% $.formClasses('name') %>">
      <input type="text" name="name" class="span12" placeholder="Style name..." id="style_name" value="<% $.form_data->{name} | H %>">
    </div>
    <div class="control-group offset1 span11<% $.formClasses('styles') %>">
      <textarea class="span12 large" id="style_styles" placeholder="Styling..." name="styles"><% $.form_data->{styles} | H %></textarea>
    </div>
  </fieldset>
  <div class="form-actions">
    <input accesskey="S" class="btn btn-primary" name="commit" type="submit" value="<% $button %>">
    <input accesskey="S" class="btn" name="_continue" type="submit" value="<% $button %> and Continue Editing">
    or <a href="<% $c -> uri_for("/admin/theme/" . $.theme_id . "/style") %>">Cancel</a>
  </div>
</form>
</%method>
