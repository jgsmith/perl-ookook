/*
 We create a row for each item in the tree with links for each action.

 config:
   sitemap: { ... } (as returned by server)
   pages: { ... }
   operations: { (callbacks for each operation available)
     delete: function(path, item) { ... }
     ...
   },
   renderers: {
     title: function(item) { ... }
     
   }

 cols: slug, title, 
 */
$.fn.tree = function(config) {
  var tableEl = this, ops;

  ops = config.operations || {};

  ops.removeItem = ops.removeItem || function(path, item, cb) { cb(); };

  var renderLine = function(slug, item, path, parent) {
    var el = $("<tr></tr>"), td, i, t, n, pageTitleTd;
    item.el = el;
    td = $("<td></td>");
    t = "";
    n = path.length;
    //item.path = path.concat([slug]);
    for(i = 0; i < n; i += 1) {
      t += "&mdash;";
    }
    t += " " + slug;
    td.append(t);
    item.el.append(td);
    td = $("<td></td>");
    if(item.hasOwnProperty("visual")) {
      if(config.pages.hasOwnProperty(item.visual)) {
        if(config.pages[item.visual].title != "") {
          td.text(config.pages[item.visual].title);
        }
        else {
          td.append("&mdash;");
        }
        pageTitleTd = td;
      }
      else {
        td.text("Unknown page: " + item.visual);
      }
    }
    item.el.append(td);
    td = $("<td></td>");
    if(ops.editItem) {
      t = $("<a href='#' class='edit'>Edit Page</a>");
      t.click(function() {
        ops.editItem(path, item, function() {
          pageTitleTd.text(config.pages[item.visual].title);
        });
      });
      td.append(t);
      td.append($("<span class='separator'>&nbsp;</span>"));
    }
    if(ops.addChild) {
      t = $("<a href='#' class='add'>Add Child</a>");
      // add click handler for adding a child
      t.click(function() {
        ops.addChild(item.path, item, function(newSlug, newItem) {
          var newEl, oldEl;
          newItem.path = path.concat([newSlug]);
          if(!item.hasOwnProperty("children")) {
            item.children = {};
          }
          if(item.children.hasOwnProperty(newSlug)) {
            oldEl = item.children[newSlug].el;
          }
          item.children[newSlug] = newItem;
          newEl = renderLine(newSlug, newItem, newItem.path, item);
          if(oldEl) {
            oldEl.replace(newEl);
          }
          else {
            item.el.after(newEl);
          }
        });
      });
      td.append(t);
      td.append($("<span class='separator'>&nbsp;</span>"));
    }

    if(ops.removeItem) {
      t = $("<a href='#' class='delete'>Remove</a>");
      t.click(function() {
        ops.removeItem(path, item, function() {
          var p, hasChildren = false;
          if(item.hasOwnProperty('children') && item.children) {
            for(p in item.children) {
              if(item.children.hasOwnProperty(p)) {
                hasChildren = true;
                break;
              }
            }
          }
          if(hasChildren) {
          }
          else {
            delete parent.children[slug];
            item.el.remove();
          }
        });
      });
      td.append(t);
      td.append($("<span class='separator'>&nbsp;</span>"));
    }
    item.el.append(td);
    
    return item.el;
  };

  var walkTree = function(sitemap, path) {
    var slugs = [];
    path = path || [];
    $.each(sitemap.children, function(slug) { slugs.push(slug); });
    slugs.sort();
    $.each(slugs, function(idx, slug) {
      var item = sitemap.children[slug];
      if(path.length == 0 && slug == '') {
        tableEl.append(renderLine("Home", item, path, sitemap));
      }
      else {
        tableEl.append(renderLine(slug, item, path, sitemap));
      }
      item.path = path.concat([slug]);
      if(item.hasOwnProperty("children")) {
        walkTree(item, item.path);
      }
    });
  };

  walkTree({children: config.sitemap}, 0);
};

var ookook = {};
ookook.ajax = function(config) {
  var ops;
  ops = {
    url: config.url,
    type: config.type,
    contentType: 'application/json',
    processData: false,
    dataType: 'json',
    success: config.success,
    error: config.error
  };
  if(config.data != null) {
    ops.data = JSON.stringify(config.data);
  }
  return $.ajax(ops);
};
