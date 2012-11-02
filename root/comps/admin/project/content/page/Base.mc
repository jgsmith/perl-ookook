<%args>
$.page
$.form_data => sub { +{} }
</%args>

<%shared>
$.project_id => sub { shift -> project -> id }
</%shared>

<%method form($title, $button)>
<script src="<% $c -> uri_for("/static/js/ace/ace.js") %>" type="text/javascript" charset="utf-8"></script>
% my $count;
<script>
  var editors = {};
</script>
<form method="POST" class="well form-horizontal" id="page-edit-form">
  <fieldset>
    <legend><% $title %></legend>
    <div class="row-fluid">
      <div class="control-group offset1 span11<% $.formClasses('title') %>">
        <input type="text" name="title" class="span12" placeholder="Page title..." id="page_title" value="<% $.form_data->{title} | H %>">
      </div>
    </div>
    <div class="row-fluid">
      <div class="control-group offset1 span11<% $.formClasses('slug') %>">
        <input type="text" name="slug" class="span12" placeholder="Slug..." id="page_slug" value="<% $.form_data->{slug} | H %>">
      </div>
    </div>
    <div class="row-fluid" style="margin-bottom: 0; padding-bottom: 0;">
      <div id="tab_toolbar" style="float: right;">
        <a class="btn" data-toggle="modal" href="#newPagePartModal" title="Add Part">
          <i class="icon icon-plus"></i>
        </a>
      </div>
      <ul class="nav nav-tabs" id="page-parts-tabs" style="margin-bottom: 0; padding-bottom: 0;">
%       $count = 1;
%       for my $part (@{$.form_data->{part}}) {
%         next unless defined $part;
          <li <% ($count == 1) ? 'class="active"' : '' %>>
            <a data-toggle="tab" href="#page_part_<% $count %>">
              <span class="pagePartName"><% $part->{name} %></span>
              <i class="icon icon-remove-circle"></i>
            </a>
          </li>
%         $count ++;
%       }
      </ul>
    </div>
    <div class="tab-content" id="pages" style="background-color: #fff; border: 1px solid #ccc; padding: 3px; margin-top: 0; border-top: none; margin-bottom: 3px; padding-bottom: 0px;">
%     $count = 1;
%     for my $part (@{$.form_data->{part}}) {
%       next unless defined $part;
        <div class="tab-pane <% ($count == 1) ? "active" : "" %>" id="page_part_<% $count %>">
          <input type="hidden" name="part[<% $count %>][name]" value=<% $part->{name} | H %>>
          <div class="control-group">
            <label class="control-label">Filter:</label>
            <div class="controls">
              <select id="filter-<% $count %>" name="part[<% $count %>][filter]">
%               for my $opt (map { s{^.*::}{}; $_ } $c->formatters) {
                  <option value="<% $opt %>" <% $.ifEqual($opt, $part->{filter}, ' selected') %>><% $opt %></option>
%               }
              </select>
            </div>
          </div>
          <div class="control-group">
            <pre id="textarea-<% $count %>" class="large span12" name="part[<% $count %>][content]" style="position: relative !important; height: 30em;"><% $part->{content} | H %></pre>
          </div>
        </div> 
        <script>
          $(function() {
            var editor = ace.edit("textarea-<% $count %>");
            editor.session.setMode("ace/mode/textile");
            editor.setTheme("ace/theme/dreamweaver");
            editor.renderer.setShowGutter(false);
            editor.renderer.setShowPrintMargin(false);
            editor.setShowInvisibles(true);
            var modes = {
              "Textile": "textile",
              "Markdown": "markdown",
              "HTML": "html",
              "Pod": "perl",
              "BBCode": "text"
            };
            $("#filter-<% $count %>").change(function() {
              var m = modes[$(this).val()];
              editor.session.setMode("ace/mode/" + m);
            });
            var m = modes[$("#filter-<% $count %>").val()];
            editor.session.setMode("ace/mode/" + m);
            editors["part[<% $count %>][content]"] = editor;
          });
        </script>
%     $count ++;
%     }
    </div>

    <div class="control-group<% $.formClasses('theme_layout') %>">
      <label class="control-label" for="page_theme_layout">Layout:</label>
      <div class="controls">
        <select name="theme_layout" id="page_theme_layout">
          <option value="">&lt;none&gt;</option>
%         for my $layout (@{$.project->theme->theme_layouts||[]}) {
%           next unless defined $layout;
            <option value="<% $layout->id %>"<% $.ifEqual($layout->id,$.form_data->{theme_layout},' selected') %>><% $layout->name | H %></option>
%         }
        </select>
      </div>
    </div>
    <div class="control-group<% $.formClasses('status') %>">
      <label class="control-label" for="page_status">Status:</label>
      <div class="controls">
        <select name="status" id="page_status">
          <option value="100"<% $.ifEqual(100,$.form_data->{status},' selected') %>>Draft</option>
          <option value="0"<% $.ifEqual(0,$.form_data->{status},' selected') %>>Approved</option>
        </select>
      </div>
    </div>
  </fieldset>
  <div class="form-actions">
    <input accesskey="S" class="btn btn-primary" name="commit" type="submit" value="<% $button %>">
    or <a href="<% $c -> uri_for("/admin/project/" . $.project_id . "/page") %>">Cancel</a>
  </div>
</form>
<div class="modal fade" id="newPagePartModal">
  <div class="modal-header">
    <button type="button" class="close" data-dismiss="modal">&times;</button>
    <h3>Add Page Part</h3>
  </div>
  <div class="modal-body">
    <label>Name:</label>
    <input type="text" id="newPagePartName" />
  </div>
  <div class="modal-footer">
    <a href="#" class="btn" data-dismiss="modal">Close</a>
    <a href="#" class="btn btn-primary" id="newPagePartModalSubmit">Add page part</a>
  </div>
</div>
<div class="modal fade" id="removePagePartModal">
  <div class="modal-header">
    <button type="button" class="close" data-dismiss="modal">&times;</button>
    <h3>Remove Page Part</h3>
  </div>
  <div class="modal-body">
    <p>Are you sure you want to remove the <span id="pagePartName"></span> page part?</p>
  </div>
  <div class="modal-footer">
    <a href="#" class="btn" data-dismiss="modal">Cancel</a>
    <a href="#" class="btn btn-primary" id="removePagePartModalSubmit">Remove page part</a>
  </div>
</div>
<script>
  $(function() {
    var page_part_count = <% scalar(@{$.page->page_parts}) %>;
    var showPagePartTab = function(e) {
      e.preventDefault();
      $(this).tab('show');
    };
    var removePagePartId, removePagePartTab;
    var removePagePart = function() {
      // we want to confirm that we want to delete this page part
      removePagePartId = $(this).parent().attr("href");
      removePagePartTab = $(this).parent();
      var name = $(this).parent().find("span.pagePartName").text();
      $("#pagePartName").text(name);
      $("#removePagePartModal").modal("show");
    };
    $("#removePagePartModalSubmit").click(function() {
      // we really want to remove it
      $("#removePagePartModal").modal("hide");
      $(removePagePartId).remove();
      $(removePagePartTab).remove();
      $("#page-parts-tabs a:first").tab("show");
    });
      
    $("#page-parts-tabs a").click(showPagePartTab);
    $("#page-parts-tabs a:first").tab('show');
    $(".icon-remove-circle").css('opacity', 0.5);
    $(".icon-remove-circle").hover(function() {
      $(this).css("opacity", 1.0);
    }, function() {
      $(this).css("opacity", 0.5);
    });
    $(".icon-remove-circle").click(removePagePart);
    $("#newPagePartModal").modal("hide");
    $("#newPagePartModalSubmit").click(function() {
      var name = $("#newPagePartName").val();
      var tmpl = '<div class="tab-pane" id="page_part_$count">' +
                 '<input type="hidden" name="part[$count][name]" value="$name" />' +  
            '<div class="control-group"><label class="control-label">Filter:</label> <div class="controls">' +
            '<select id="filter-$count" name="part[$count][filter]">' +
%         for my $opt (map { s{^.*::}{}; $_ } OokOok->formatters) {
            '<option value="<% $opt %>"><% $opt %></option>' +
%         }
        '</select></div></div>' +
        '<div class="control-group"><pre id="textarea-$count" name="part[$count][content]" class="span12 large" style="position: relative !important; height: 30em;"></pre></div>' +   
        '</div>';
      if(name === undefined || name == null) { return; }
      name = name.replace(/\s+/g, ' ').replace(/^\s+/,'').replace(/\s+$/,'');
      if(name === "") { return; }
      $("#newPagePartModal").modal("hide");
      // TODO: check for existing page part with this name
      page_part_count += 1;
      while(tmpl.indexOf('$count') >= 0) {
        tmpl = tmpl.replace('$count', page_part_count);
      }
      while(tmpl.indexOf('$name') >= 0) {
        tmpl = tmpl.replace('$name', name);
      }
      $("#pages").append($(tmpl));
      var tab = $("<li><a data-toggle='tab' href='#page_part_" + page_part_count + "'><span class='pagePartName'>" + name + "</span> <i class='icon icon-remove-circle'></i></a></li>");
      $("#page-parts-tabs").append(tab);
      $(tab).find("a").click(showPagePartTab);
      $(tab).find(".icon-remove-circle").click(removePagePart);
      $(tab).find(".icon-remove-circle").css('opacity', 0.5);
      $(tab).find(".icon-remove-circle").hover(function() {
        $(this).css("opacity", 1.0);
      }, function() {
        $(this).css("opacity", 0.5);
      });
      $(tab).find("a").tab('show');
      var editor = ace.edit("textarea-" + page_part_count);
      editor.session.setMode("ace/mode/textile");
      editor.setTheme("ace/theme/dreamweaver");
      editor.renderer.setShowGutter(false);
      editor.renderer.setShowPrintMargin(false);
      editor.setShowInvisibles(true);
      var modes = {
        "Textile": "textile",
        "Markdown": "markdown",
        "HTML": "html",
        "Pod": "perl",
        "BBCode": "text"
      };
      $("#filter-" + page_part_count).change(function() {
        var m = modes[$(this).val()];
        editor.session.setMode("ace/mode/" + m);
      });
      editor.session.setMode("ace/mode/textile");
      editors["part[" + page_part_count + "][content]"] = editor;
    });

    $("#page-edit-form").submit(function() {
      // we need to convert all of the ace editing areas into hidden variables
      var formEl = $("#page-edit-form");
      
      $.each(editors, function(name, editor) {
        var el = $("<input type='hidden' name='" + name + "'/>");
        el.val(editor.getValue());
        formEl.append(el);
      });
      return true;
    });
  });
</script>
</%method>
