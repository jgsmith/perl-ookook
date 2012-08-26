<%args>
$.theme_variable
$.form_data => sub { +{} }
</%args>

<%method form($title, $button)>
<form method="POST" class="well form-horizontal">
  <fieldset>
    <legend><% $title %></legend>
    <div class="control-group offset1 span11<% $.formClasses('name') %>">
      <input type="text" name="name" class="span12" placeholder="Variable name..." id="variable_name" value="<% $.form_data->{name} | H %>">
    </div>
    <div class="control-group offset1 span11<% $.formClasses('description') %>">
      <textarea name="description" class="span12 large" placeholder="Variable description..." id="variable_name"><% $.form_data->{name} | H %></textarea>
    </div>
    <div class="control-group<% $.formClasses('type') %>">
      <label class="control-label">Type:</label>
      <div class="controls">
        <select name="type">
%         for my $v (qw/color font length percent/) {
            <option value="<% $v %>" <% $.ifEqual($v, $.form_data->{type}, ' selected') %>><% $v %></option>
%         }
        </select>
      </div>
    </div>
    <div class="offset1 span11 control-group<% $.formClasses('default_value') %>">
      <input type="text" name="default_value" value="<% $.form_data->{default_value} | H %>" class="span12" placeholder="Default value..." />
    </div>
  </fieldset>
  <div class="form-actions">
    <input accesskey="S" class="btn btn-primary" name="commit" type="submit" value="<% $button %>">
    or <a href="<% $c -> uri_for("/admin/theme/" . $.theme_id . "/layout") %>">Cancel</a>
  </div>
</form>
</%method>
