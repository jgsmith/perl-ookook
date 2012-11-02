<%args>
$.pages => sub { [] }
</%args>

<%method renderPage($page, $indent)>
% my $parent = $page -> parent_page ? "child-of-node-" . $page->parent_page->id : "";
% $.IndexItem("$parent", "node-" . $page->id) {{
%   $.IndexItemName("page", "/admin/project/" . $.project_id . "/page/" . $page->id . "/edit") {{
      <% $page->title | H %>
%   }}
%   $.IndexItemStatus {{
%     if($page->source_version->edition->is_closed) {
        Published
%     }
%     elsif($page->status == 0) {
        Approved
%     }
%     elsif($page->status == 100) {
        Draft
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
      <% $.IndexItemTargetedAction(
           0,
           "/dev/v/" . $.project_id . '/' . $page->slug_path,
           "screenshot",
           "Preview",
           "_" . $page->id
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

% # <table id="index-table" class="table table-striped">
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
<script>
  $(function() {
    $("#index-table").treeTable({
      persist: true,
      persistStoreName: "ookook-project-pages-<% $.project_id %>",
      initialState: "expanded"
    });
  });
</script>
