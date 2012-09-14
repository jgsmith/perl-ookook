<%args>
$.pages => sub { [] }
</%args>

<%method renderPage($page, $indent)>
% $.IndexItem("level_" . $indent . " page") {{
%   $.IndexItemName("page", "/admin/project/" . $.project_id . "/page/" . $page->id . "/edit") {{
      <% "&mdash;&nbsp;" x $indent %><% $page->title | H %>
%   }}
%   $.IndexItemStatus {{
%     if($page->source_version->edition->is_closed) {
        Published
%     }
%     else {
        Modified
%     }
%   }}
%   $.IndexItemActions {{
      <% $.IndexItemAction(
           0,
           "/admin/project/".$.project_id."/page/".$page->id."/child", 
           "plus-sign", 
           "Add Child"
      ) %>
      <% $.IndexItemAction(
           $page->source_version->edition->is_closed,
           "/admin/project/".$.project_id."/page/".$page->id."/discard", 
           "minus-sign", 
           "Discard Changes"
      ) %>
%   }}
% }}
</%method>
<%method renderPages($page)>
% my @pages = [ $page, 0 ];
% my $p;
% while(@pages) {
%   $p = pop @pages;
%   next unless defined $p -> [0];
%   push @pages, reverse map { [ $_, $p->[1]+1 ] } $p -> [0] -> child_pages;
    <% $.renderPage(@$p) %>
% }
</%method>

% $.IndexTable {{
%   $.IndexHead {{
      <% $.IndexHeadName("Page") %>
      <% $.IndexHeadStatus("Status") %>
      <% $.IndexHeadActions("Modify") %>
%   }}
%   $.IndexBody {{
      <% $.renderPages($.project->home_page) %>
%   }}
% }}
