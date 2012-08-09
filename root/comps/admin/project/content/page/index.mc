<%args>
$.pages => sub { [] }
</%args>

<%method renderPage($page, $indent)>
% my $page_id = $page->id;
% $.IndexItem("level_" . $indent . " page") {{
%   $.IndexItemName("page", "/admin/project/" . $.project_id . "/page/" . $page_id . "/edit") {{
      <% $page->title | H %>
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
           "", 
           "plus-sign", 
           "Add Child"
      ) %>
      <% $.IndexItemAction(
           $page->source_version->edition->is_closed,
           "", 
           "minus-sign", 
           "Discard Changes"
      ) %>
%   }}
% }}
</%method>
<%method renderPages($page)>
% my @pages = [ [ $page, 0 ] ];
% my $p;
% while(@pages) {
%   $p = pop @pages;
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
      <% $.renderPage($.project->page, 0) %>
%   }}
% }}
