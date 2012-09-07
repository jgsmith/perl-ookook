<%args>
$.theme_layout
$.form_data => sub { +{} }
</%args>

<%method form($title, $button)>
<form method="POST" class="well form-horizontal">
  <fieldset>
    <legend><% $title %></legend>
    <div class="control-group offset1 span11<% $.formClasses('name') %>">
      <input type="text" name="name" class="span12" placeholder="Layout name..." id="layout_name" value="<% $.form_data->{name} | H %>">
    </div>
    <div class="control-group offset1 span11<% $.formClasses('layout') %>">
      <textarea class="span12 large" id="layout_layout" placeholder="Layout content..." name="layout"><% $.form_data->{layout} | H %></textarea>
    </div>
    <div class="control-group<% $.formClasses('theme_style') %>">
      <label class="control-label" for="layout_theme_style">Style</label>
      <div class="controls">
        <select name="theme_style" id="layout_theme_style">
          <option value="">&lt;none&gt;</option>
%         for my $style (@{$.theme -> theme_styles||[]}) {
            <option value="<% $style->id %>"<% $.ifEqual($style->id, $.form_data->{'theme_style'}, ' selected') %>><% $style->name %></option>
%         }
        </select>
      </div>
    </div>
    <div class="control-group<% $.formClasses('parent_layout') %>">
      <label class="control-label" for="layout_theme_parent">Parent Layout</label>
      <div class="controls">
        <select name="parent_layout" id="layout_theme_parent">
          <option value="">&lt;none&gt;</option>
%         for my $layout (@{$.theme->theme_layouts||[]}) {
%         if(!defined($.theme_layout) || $.theme_layout->id ne $layout->id) {
            <option value="<% $layout->id %>"<% $.ifEqual($layout->id, $.form_data->{'parent_layout'}, ' selected') %>><% $layout->name %></option>
%         }
%         }
        </select>
      </div>
    </div>
  </fieldset>
  <div class="form-actions">
    <input accesskey="S" class="btn btn-primary" name="commit" type="submit" value="<% $button %>">
    <input accesskey="S" class="btn" name="_continue" type="submit" value="<% $button %> and Continue Editing">
    or <a href="<% $c -> uri_for("/admin/theme/" . $.theme_id . "/layout") %>">Cancel</a>
  </div>
</form>
</%method>
