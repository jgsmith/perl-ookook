<%args>
$.form_data => sub { +{} }
</%args>

<form method="POST" class="well form-horizontal">
  <fieldset>
    <legend>New Project</legend>
    <div class="control-group offset1 span11<% $.formClasses('name') %>">
      <input type="text" name="name" class="span12" placeholder="Project name...">
    </div>
    <div class="control-group offset1 span11<% $.formClasses('description') %>">
      <textarea name="description" class="span12 large" placeholder="Project description..."></textarea>
    </div>
    <div class="control-group<% $.formClasses('theme') %>">
      <label class="control-label" for="project_theme">Project Theme</label>
      <div class="controls">
        <select name="theme">
%         for my $theme (@{$c->stash->{themes}||[]}) {
            <option value="<% $theme->id %>"<% $.ifEqual($theme->id, $.form_data->{theme}, ' selected') %>><% $theme->name %></option>
%         }
        </select>
      </div>
    </div>
  </fieldset>
  <div class="form-actions">
    <input accesskey="S" class="btn btn-primary" name="commit" type="submit" value="Create Project"> or <a href="<% $c -> uri_for("/admin/project") %>">Cancel</a>
  </div>
</form>
