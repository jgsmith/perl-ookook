<%augment sub_nav_tabs>
  <li class="active"><a href="<% $c->uri_for("/admin/theme/".$.theme_id."/settings") %>">General</a></li>
  <li><a href="<% $c->uri_for("/admin/theme/".$.theme_id."/editions") %>">Editions</a></li>
</%augment>
