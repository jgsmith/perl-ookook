<%args>
$.form_data => sub { +{} }
$.is_admin => sub { $_[0] -> board -> c -> user && $_[0] -> board -> c -> user -> has_permission($_[0] -> board, "board.admin") }
$.ranks => sub { [ sort { $a->position <=> $b->position } @{$_[0] -> board -> board_ranks} ] }
$.rank_names => sub { +{ map { $_->id => $_->name } @{$_[0] -> board -> board_ranks} } }
</%args>
% if($.is_admin) {
<form method="POST" class="form-horizontal">
% }
% $.IndexTable {{
%   $.IndexHead {{
      <% $.IndexHeadName("Permission") %>
      <% $.IndexHeadCol("", "Unlocked") %>
      <% $.IndexHeadCol("", "Locked") %>
%   }}
%   $.IndexBody {{
      <% $.IndexPermissionGroup("Board") %>

      <% $.IndexPermission("Promote Member", "board.member.promote") %>
      <% $.IndexPermission("Demote Member", "board.member.demote") %>
      <% $.IndexPermission("Induct Member", "board.member.add") %>
      <% $.IndexPermission("Dismiss Member", "board.member.remove") %>

      <% $.IndexPermissionGroup("Projects") %>

      <% $.IndexPermission("Toggle Project Lock", "project.lock") %>
      <% $.IndexPermission("Publish Editions", "project.edition.publish") %>

      <% $.IndexPermission("Modify Pages", "project.page.edit") %>
      <% $.IndexPermission("Approve Page Changes", "project.page.status") %>
      <% $.IndexPermission("Revert Page Changes", "project.page.revert") %>

      <% $.IndexPermission("Modify Snippets", "project.snippet.edit") %>
      <% $.IndexPermission("Approve Snippet Changes", "project.snippet.status") %>
      <% $.IndexPermission("Revert Snippet Changes", "project.snippet.revert") %>

%     if($.board -> may_have_resource('theme')) {
        <% $.IndexPermissionGroup("Themes") %>

        <% $.IndexPermission("Toggle Theme Lock", "theme.lock") %>
        <% $.IndexPermission("Publish Editions", "theme.edition.publish") %>

        <% $.IndexPermission("Modify Layouts", "theme.layout.edit") %>
        <% $.IndexPermission("Approve Layout Changes", "theme.layout.status") %>
        <% $.IndexPermission("Revert Layout Changes", "theme.layout.revert") %>

        <% $.IndexPermission("Modify Snippets", "theme.snippet.edit") %>
        <% $.IndexPermission("Approve Snippet Changes", "theme.snippet.status") %>
        <% $.IndexPermission("Revert Snippet Changes", "theme.snippet.revert") %>
%     }
%   }}
% }}
% # we also need to know which ranks can manage which resource types
% $.IndexTable {{
%   $.IndexHead {{
      <% $.IndexHeadName("Rank") %>
      <% $.IndexHeadCol("", "Projects") %>
% if($.board -> may_have_resource('theme')) {
      <% $.IndexHeadCol("", "Themes") %>
% }
% if($.board -> may_have_resource('typeface')) {
      <% $.IndexHeadCol("", "Typefaces") %>
% }
%   }}
%   $.IndexBody {{
%     for my $rank (@{$.ranks}) {
%       next if !$rank -> position;
%       $.IndexItem {{
%         $.IndexItemName("", "") {{
            <% $rank -> name | H %>
%         }}
%         $.IndexItemCol("") {{
            <input type="checkbox" name="allowed.project" value="<% $rank->id %>" />
%         }}
%         if($.board -> may_have_resource('theme')) {
%           $.IndexItemCol("") {{
              <input type="checkbox" name="allowed.theme" value="<% $rank->id %>" />
%           }}
%         }
%         if($.board -> may_have_resource('typeface')) {
%           $.IndexItemCol("") {{
              <input type="checkbox" name="allowed.typeface" value="<% $rank->id %>" />
%           }}
%         }
%       }}
%     }
%   }}
% }}
% if($.is_admin) {
<div class="form-actions">
<input accesskey="S" class="btn btn-primary" name="commit" type="submit" value="Update Permissions">
or <a href="<% $c -> uri_for("/admin/board/".$.board_id."/settings") %>">Cancel</a>
</div>
</form>
% }

<%method IndexPermissionGroup ($title)>
<tr><td colspan="3"><h2><% $title | H %></h2></td></tr>
</%method>

<%method IndexPermission ($title, $perm)>
% $.IndexItem {{
%   $.IndexItemName("","") {{
      <% $title | H %>
%   }}
%   if($perm =~ m{^board\.}) {
%     $.IndexItemCol("") {{
        <% $.SelectOrText($perm) %>
%     }}
      <td></td>
%   }
%   else {
%     $.IndexItemCol("") {{
        <% $.SelectOrText("unlocked.".$perm) %>
%     }}
%     $.IndexItemCol("") {{
        <% $.SelectOrText("locked.".$perm) %>
%     }}
% }
% }}
</%method>

<%method SelectOrText ($perm)>
% my $pid = $perm;
% $pid =~ tr{.}{,};
% my $rank_uuid = $.form_data->{permissions} -> {$perm};
% if($.is_admin) {
  <select name="<% $pid %>">
% for my $rank (@{$.ranks}) {
    <option value="<% $rank -> id %>" <% 
      defined($rank_uuid) && $rank_uuid eq $rank->id ? 'selected' : '' 
    %> ><% $rank -> name | H %></option>
% }
  </select>
% }
% else {
    <% ($.rank_names -> {$rank_uuid} || $.ranks->[0]->name) | H %>
% }
</%method>
