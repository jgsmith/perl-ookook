<%args>
$.form_data => sub { +{} }
</%args>

<form method="POST" class="well form-horizontal">
  <fieldset>
    <legend>New Typeface</legend>
    <div class="control-group offset1 span11<% $.formClasses('name') %>">
      <input type="text" name="name" class="span12" placeholder="Typeface name..." value="<% $.form_data->{name} | H %>">
    </div>
    <div class="control-group offset1 span11<% $.formClasses('description') %>">
      <textarea name="description" class="span12 large" placeholder="Typeface description..."><% $.form_data->{description} | H %></textarea>
    </div>
  </fieldset>
  <div class="form-actions">
    <input accesskey="S" class="btn btn-primary" name="commit" type="submit" value="Create Typeface"> or <a href="<% $c->uri_for("/admin/typeface") %>">Cancel</a>
  </div>
</form>
