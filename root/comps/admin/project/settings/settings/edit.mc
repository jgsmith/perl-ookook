<%args>
$.form_data => sub { +{} }
</%args>

<form method="POST" class="form-horizontal">
  <fieldset>
    <legend><h1>Edit Configuration</h1></legend>
    <div class="control-group offset1 span11<% $.formClasses('name') %>">
      <input type="text" name="name" class="span12" placeholder="Project name..." value="<% $.form_data->{name} | H %>">
    </div>
    <div class="control-group offset1 span11<% $.formClasses('description') %>">
      <textarea name="description" class="span12 large" placeholder="Project description..."><% $.form_data->{description} %></textarea>
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
    <input accesskey="S" class="btn btn-primary" name="commit" type="submit" value="Update Configuration"> or <a href="<% $c->uri_for("/admin/project/" . $.project_id . "/settings") %>">Cancel</a>
  </div>
</form>

