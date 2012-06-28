$.fn.tree = (config) ->
  tableEl = this
  ops = config.operations
  ops.removeItem = ops.removeItem || (path, item, cb) -> cb()
  renderLine = (slug, item, path, parent) ->
    el = $("<tr class='hoverable'></tr>")
    item.el = el
    td = $("<td></td>")
    t = ""
    n = path.length
    for i in [0...n]
      t += "&mdash;"
    t += " " + slug
    td.append t
    item.el.append td
    td = $("<td></td>")
    if item.hasOwnProperty "visual"
      if config.pages.hasOwnProperty item.visual
        if config.pages[item.visual].title? && config.pages[item.visual].title != ""
          td.text(config.pages[item.visual].title)
        else
          td.append("&mdash;")
        pageTitleTd = td
      else
        td.text("Unknown page: " + item.visual)
    item.el.append(td)
    td = $("<td><div class='btn-group'></div></td>")
    t = $("<button class='btn'>Edit</button>")
    t.click ->
      ops.editItem path, item, ->
        pageTitleTd.text config.pages[item.visual].title
    td.find(".btn-group").append(t)
    td.find(".btn-group").append($("<button class='btn dropdown-toggle' data-toggle='dropdown'><span class='caret'></span></button>"))
    td.find(".btn-group").append("<ul class='dropdown-menu'></ul>")
    t = $("<a href='#'>Edit</a>")
    t.click ->
      ops.editItem path, item, ->
        pageTitleTd.text(config.pages[item.visual].title)

    td.find(".dropdown-menu").append(t)

    if item.visual?
      t = $("<a href='#'>Preview</a>")
      t.click ->
        ops.previewItem(item.path, item)

      td.find(".dropdown-menu").append(t)

    t = $("<a href='#'>Add</a>")
    # add click handler for adding a child
    t.click ->
      ops.addChild item.path, item, (newSlug, newItem) ->
        newItem.path = path.concat([newSlug])
        if !item.hasOwnProperty("children")
          item.children = {}

        if item.children.hasOwnProperty(newSlug)
          oldEl = item.children[newSlug].el

        item.children[newSlug] = newItem
        newEl = renderLine newSlug, newItem, newItem.path, item
        if oldEl?
          oldEl.replaceWith(newEl)
        else 
          item.el.after(newEl)

    td.find(".dropdown-menu").append(t)

    t = $("<a href='#'>Remove</a>")

    t.click -> ops.removeItem path, item, item.remove

    item.remove = ->
      hasChildren = false;
      if item.hasOwnProperty('children') and item.children
        for p of item.children
          if item.children.hasOwnProperty p
            hasChildren = true
            break

      if hasChildren
      else
        delete parent.children[slug]
        item.el.fadeOut 'slow', -> item.el.remove()
        if !parent.visual?
          parent.remove()

    td.find(".dropdown-menu").append(t)

    item.el.append(td)

    item.el

  walkTree = (sitemap, path) ->
    slugs = []
    path = path || []

    if sitemap.hasOwnProperty('children') and sitemap.children?
      slugs = (slug for slug of sitemap.children)
    slugs.sort()
    for slug in slugs
      item = sitemap.children[slug]
      if path.length == 0 and slug == ''
        tableEl.append renderLine("Home", item, path, sitemap)
      else
        tableEl.append renderLine(slug, item, path, sitemap)
      item.path = path.concat([slug])
      if item.hasOwnProperty("children")
        walkTree(item, item.path)

  walkTree({children: config.sitemap}, 0)


MITHGrid.globalNamespace "ookook", (ookook) ->
  ookook.namespace "config", (config) ->
    config.url_base = '/';

  ookook.namespace "util", (util) ->
    util.ajax = (config) ->
      ops = 
        url: config.url
        type: config.type
        contentType: 'application/json'
        processData: false
        dataType: 'json'
        success: config.success
        error: config.error

      if config.data?
        ops.data = JSON.stringify config.data

      $.ajax ops

    util.get  = (config) -> ookook.util.ajax $.extend({ type: 'GET' },  config)
    util.post = (config) -> ookook.util.ajax $.extend({ type: 'POST' }, config)
    util.put  = (config) -> ookook.util.ajax $.extend({ type: 'PUT' },  config)
    util.delete  = (config) -> ookook.util.ajax $.extend({ type: 'DELETE' }, config)

    util.success_message = (msg) ->
      div = $("<div class='alert alert-success'><a class='close' data-dismiss='alert' href='#'>&times;</a><h4 class='alert-heading'>Success!</h4></div>");
      div.append(msg);
      $("#messages").append(div);
      setTimeout ->
        div.animate {
          opacity: 0
        }, 1000, ->
          div.remove()
      , 2000

    util.error_message = (msg) ->
      div = $("<div class='alert alert-error'><a class='close' data-dismiss='alert' href='#'>&times;</a><h4 class='alert-heading'>Uh oh!</h4></div>");
      div.append(msg);
      $("#messages").append(div);


  ookook.namespace "Model", (Model) ->
    makeModel = (config) ->
      maker = (that) ->
        that.update = (json, cb) ->
          ookook.util.put
            url: that.url
            data: json
            success: (data) -> cb(maker(data))
            error: -> cb()

        that.delete = (cb) ->
          ookook.util.delete
            url: that.url,
            success: -> cb true
            error: -> cb false

        if config.extender?
          config.extender that

        that

      model = (id, cb) ->
        ookook.util.get
          url: ookook.config.url_base + config.collection_url + '/' + id
          success: (that) -> cb maker that
          error: -> cb()

      model.create = (json, cb) ->
        ookook.util.post
          url: ookook.config.url_base + config.collection_url
          data: json
          success: (that) -> cb maker that
          error: -> cb()

      model

    makeCollectionGetter = (config) ->
      (cb) ->
        ookook.util.get
          url: ookook.config.url_base + config.collection_url
          success: (that) ->
            for thing in that[config.key]
              cb thing
            cb()
          error: -> cb()

    Model.project = makeModel
      name: 'project'
      collection_url: 'project'
      extender: (that) ->
        that.pages = makeCollectionGetter
          collection_url: 'project/' + that.id + '/page'
          key: 'pages'

    Model.projects = makeCollectionGetter
      collection_url: 'project'
      key: 'projects'

    Model.library = makeModel
      name: 'library'
      collection_url: 'library'

    Model.libraries = makeCollectionGetter
      collection_url: 'library'
      key: 'libraries'

    Model.initModel = makeModel;
    Model.initCollection = makeCollectionGetter;


  ookook.namespace "Component", (component) ->
    component.namespace "ModalForm", (modalForm) ->
      modalForm.initInstance = (args...) ->
        MITHGrid.initInstance 'ookook.Component.ModalForm', args..., (that, container) ->
          options = that.options
          id = $(container).attr('id')
          $(container).modal('hide')
          $("#" + id + "_cancel").click ->
            $(container).modal('hide')
          $("#" + id + "_action").click ->
            data = {}
            $(container).find('.modal-form-input').each (idx, el) ->
              el = $(el)
              elId = el.attr('id')
              elId = elId.substr(id.length + 1)
              data[elId] = el.val()
            if options.createCallback?
              $(container).modal('hide')
              options.createCallback(data)
            else if ookook.Model[options.model]?.create?
              ookook.Model[options.model].create data, (res) ->
                if res?
                  $(container).modal('hide')
                  that.events.onCreate.fire(res)
            else
              $(container).modal('hide')

          $(container).on 'show', ->
            $(container).find('.modal-form-input').val("")
        
  ookook.namespace "Presentation", (presentation) ->
    presentation.namespace "NavList", (navlist) ->
      navlist.initInstance = (args...) ->
        MITHGrid.Presentation.initInstance 'ookook.Presentation.NavList', args..., (that, container) ->
          createObjectUI = ookook.Controller.CreateObjectUI.initInstance()
          options = that.options
          sectionEls = {}
          navList = {}
          that.selfRender = ->
            $(container).empty();
            navList = $('<ul class="nav nav-list"></ul>')
            $(container).append(navList)
            # we want to add headers for each of the sections and keep track of
            # them so we know where to add new items
            sectionEls = {};
            for name in options.sectionOrder
              if options.sections[name]?
                do (name) ->
                  sectionEls[name] = $("<li class='nav-header'></li>");
                  sectionEls[name].text(name);
                  navList.append(sectionEls[name]);
                  binding = createObjectUI.bind(sectionEls[name])
                  binding.events.onSelect.addListener ->
                    that.events.onCreateObject.fire name


          that.render = (c, m, i) ->
            item = m.getItem i
            sectionEl = null
            for name, el of sectionEls
              if options.sections[name]?
                sharedTypes = (t for t in item.type when t in options.sections[name].types).length
              else
                sharedTypes = 0
              if sharedTypes > 0
                sectionEl = el
            if sectionEl
              lens = that.getLens i
              if lens?
                c = $("<li></li>");
                lens.render c, that, m, i
                sectionEl.after(c)
  
  ookook.namespace "Dashboard", (dashboard) ->
    dashboard.initInstance = (args...) ->
      MITHGrid.Application.initInstance 'ookook.Dashboard', args..., (app, container) ->
        app.ready ->
          $(container).addClass('row')
          workspace = $(container).find(".ookook-workspace")
          workspaceTabs = $(workspace).find(".nav-tabs")
          workspaceContent = $(workspace).find(".tab-content")
          workspaceItems = {}
          clicker = ookook.Controller.Click.initInstance()
          navListLensGen = (icon) ->
            (el, view, model, id) ->
              rendering = {}

              a = $("<a href='#'></a>")
              a.append("<i class='icon-#{icon}'></i>")
              item = model.getItem id
              a.append(item.name[0])
              el.append(a)

              binding = clicker.bind(a)
              binding.events.onSelect.addListener ->
                if workspaceItems[id]?
                  $(workspaceItems[id].tab).find('a').tab('show')
                else
                  paneEl = $("<div id='tab-pane-#{id}' class='tab-pane'></div>")
                  $(workspaceContent).append(paneEl)
                  tabElA = $("<a data-toggle='tab' href='#tab-pane-#{id}'></a>")
                  tabElA.text(item.name[0])
                  tabEl = $("<li></li>")
                  tabEl.append(tabElA)
                  $(workspaceTabs).append(tabEl)
                  workspaceItems[id] =
                    tab: tabEl
                    pane: paneEl
                  workspaceItems[id].app = ookook.Model.Component[item.type[0]].initInstance(paneEl, { id: id, dataStore: app.dataStore.data })

                  tabElA.tab('show')

              rendering.update = (item) ->
                a.text(item.name[0])
                if workspaceItems[id]?
                  $(workspaceItems[id].tab).find("a").text(item.name[0])

              rendering.remove = ->
                el.remove()
                if workspaceItems[id]?
                  workspaceItems[id].tab.remove()
                  workspaceItems[id].pane.remove()
                  delete workspaceItems[id]
              rendering

          app.presentation.navlist.addLens 'Project', navListLensGen('briefcase')
          app.presentation.navlist.addLens 'Library', navListLensGen('book')
          app.presentation.navlist.addLens 'Database', navListLensGen('hdd')
          app.presentation.navlist.addLens 'Component', navListLensGen('picture')

          app.presentation.navlist.events.onCreateObject.addListener (t) ->
            # trigger the modal for the object type
            $("#new-#{t}-form").modal('show')
          
          ookook.Model.projects (project) ->
            if project?
              items = [{
                id: project.uuid
                type: 'Project'
                name: project.name
                url: project.url
                description: project.description
              }]
              edition_count = 0
              for edition in project.editions
                items.push
                  id: project.uuid + '-edition-' + edition_count
                  type: 'Edition'
                  project: project.uuid
                  frozen_on: edition.frozen_on
                  created_on: edition.created_on
                  name: edition.name
                  description: edition.description
                edition_count += 1
              app.dataStore.data.loadItems items

              ookook.util.get
                url: project.url + '/page'
                success: (pages) ->
                  pageList = []
                  for page in pages.pages
                    pageList.push
                      id: page.uuid
                      type: 'Page'
                      project: project.uuid
                      title: page.title
                      url: page.url
                  app.dataStore.data.loadItems pageList
              
          ookook.Model.libraries (library) ->
            if library?
              app.dataStore.data.loadItems [{
                id: library.uuid
                type: 'Library'
                name: library.name
                description: library.description
              }]

  MITHGrid.defaults 'ookook.Dashboard',
    dataStores:
      data:
        types:
          Project: {}
          Library: {}
          Database: {}
          Component: {}
          Edition: {}
          Page: {}
        properties:
          name:
            valueType: 'text'
          description:
            valueType: 'text'
          parent:
            valueType: 'item'
          project:
            valueType: 'item'
    dataViews:
      data:
        dataStore: 'data'
    presentations:
      navlist:
        type: ookook.Presentation.NavList
        dataView: 'data'
        container: ".ookook-nav-list"
        sectionOrder: ['Projects', 'Databases', 'Libraries', 'Components']
        sections:
          Projects: 
            types: ['Project']
            icon: 'briefcase'
          Libraries: 
            types: ['Library']
            icon: 'briefcase'
          Databases: 
            types: ['Database']
            icon: 'briefcase'
          Components: 
            types: ['Component']
            icon: 'briefcase'
    viewSetup: """
      <div class="span2 ookook-nav-list ">
      </div>
      <div class="span10 ookook-workspace">
        <ul class="nav nav-tabs"></ul>
        <div class="tab-content">
        </div>
      </div>
    """

  MITHGrid.defaults 'ookook.Component.ModalForm',
    events:
      onCreate: null

  MITHGrid.defaults 'ookook.Presentation.NavList',
    events:
      onCreateObject: null

  MITHGrid.defaults 'ookook.Controller.CreateObjectUI',
    bind:
      events:
        onSelect: null

  MITHGrid.defaults 'ookook.Controller.Click',
    bind:
      events:
        onSelect: null
