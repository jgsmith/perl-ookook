$.fn.tree = (config) ->
  tableEl = this
  ops = config.operations || {}
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
      ops.editItem path, item ->
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

    console.log sitemap
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


MITHGrid.globalNamespace "OokOok", (ookook) ->
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

    Model.Component = {
      Project: {}
    }
    Model.Component.Project.initInstance = (args...) ->
      MITHGrid.initInstance 'OokOok.Model.Component.Project', args..., (that, container) ->
        console.log that
        options = that.options
        projectId = options.id
        that.dataStore = options.dataStore
        item = that.dataStore.getItem projectId
        
        ul = $("<ul class='nav nav-pills'></ul>")
        $(container).append(ul)
        contentDiv = $("<div class='tab-content'></div>")
        $(container).append(contentDiv)

        sections = 
          meta: 'Meta'
          pages: 'Pages'
          snippets: 'Snippets'
          editions: 'Editions'
          users: 'Users'

        for frag in ['meta', 'pages', 'snippets', 'editions', 'users']
          name = sections[frag]
          do (frag, name) ->
            a = $("<a data-toggle='tab' href='##{projectId}-#{frag}'></a>")
            a.text(name)
            li = $("<li></li>")
            li.append(a)
            ul.append(li)
            div = $("<div id='#{projectId}-#{frag}' class='tab-pane'></div>")
            contentDiv.append(div)
            a.click ->
              a.tab('show')

            if frag == "meta"
              a.tab('show')
            if Model.Component.Project[name]?.initInstance?
              comp = Model.Component.Project[name].initInstance div, {
                dataStore: options.dataStore
                id: projectId
              }
    Model.Component.Project.Meta = {}
    Model.Component.Project.Meta.initInstance = (args...) ->
      MITHGrid.initInstance 'OokOok.Model.Component.Project.Meta', args..., (that, container) ->
        options = that.options
        projectId = options.id
        that.dataStore = options.dataStore

        $(container).append("This is the meta section!")

        that.dataStore.events.onModelChange.addListener (model, items) ->
          if projectId in items
            console.log "Project changed!"
     
    Model.Component.Project.Pages = {}
    Model.Component.Project.Pages.initInstance = (args...) ->
      MITHGrid.initInstance 'OokOok.Model.Component.Project.Pages', args..., (that, container) ->
        options = that.options
        projectId = options.id
        that.dataStore = options.dataStore

        $(container).append("This is the Pages section!")

        that.dataStore.events.onModelChange.addListener (model, items) ->
          if projectId in items
            console.log "Project changed!"
     
    Model.Component.Project.Snippets = {}
    Model.Component.Project.Snippets.initInstance = (args...) ->
      MITHGrid.initInstance 'OokOok.Model.Component.Project.Snippets', args..., (that, container) ->
        options = that.options
        projectId = options.id
        that.dataStore = options.dataStore

        $(container).append("This is the Snippets section!")

        that.dataStore.events.onModelChange.addListener (model, items) ->
          if projectId in items
            console.log "Project changed!"
     
    Model.Component.Project.Editions = {}
    Model.Component.Project.Editions.initInstance = (args...) ->
      MITHGrid.initInstance 'OokOok.Model.Component.Project.Editions', args..., (that, container) ->
        options = that.options
        projectId = options.id
        that.dataStore = options.dataStore

        $(container).append("This is the Editions section!")

        that.dataStore.events.onModelChange.addListener (model, items) ->
          if projectId in items
            console.log "Project changed!"
     
    Model.Component.Project.Users = {}
    Model.Component.Project.Users.initInstance = (args...) ->
      MITHGrid.initInstance 'OokOok.Model.Component.Project.Users', args..., (that, container) ->
        options = that.options
        projectId = options.id
        that.dataStore = options.dataStore

        $(container).append("This is the Users section!")

        that.dataStore.events.onModelChange.addListener (model, items) ->
          if projectId in items
            console.log "Project changed!"
     
  ookook.namespace "Controller", (controller) ->
    controller.namespace "CreateObjectUI", (co) ->
      co.initInstance = (args...) ->
        MITHGrid.Controller.initInstance 'OokOok.Controller.CreateObjectUI', args..., (that) ->
          that.applyBindings = (binding) ->
            el = binding.locate ''
            addIcon = $('<i style="float: right; display: none;" class="icon-plus"></i>')
            el.prepend(addIcon)
            el.hover( ( -> addIcon.show() ), ( -> addIcon.hide() ) )
            addIcon.click binding.events.onSelect.fire

    controller.namespace "Click", (click) ->
      click.initInstance = (args...) ->
        MITHGrid.Controller.initInstance 'OokOok.Controller.Click', args..., (that) ->
          that.applyBindings = (binding) ->
            el = binding.locate ''
            el.click binding.events.onSelect.fire
          
  ookook.namespace "Component", (component) ->
    component.namespace "ModalForm", (modalForm) ->
      modalForm.initInstance = (args...) ->
        MITHGrid.initInstance 'OokOok.Component.ModalForm', args..., (that, container) ->
          options = that.options
          console.log options
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
            $(container).modal('hide')
            console.log data
            console.log "Using model:", options.model

          $(container).on 'show', ->
            $(container).find('.modal-form-input').val("")
        
  ookook.namespace "Presentation", (presentation) ->
    presentation.namespace "NavList", (navlist) ->
      navlist.initInstance = (args...) ->
        MITHGrid.Presentation.initInstance 'OokOok.Presentation.NavList', args..., (that, container) ->
          createObjectUI = ookook.Controller.CreateObjectUI.initInstance()
          console.log createObjectUI
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
      MITHGrid.Application.initInstance 'OokOok.Dashboard', args..., (app, container) ->
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
                  workspaceItems[id].app = OokOok.Model.Component[item.type[0]].initInstance(paneEl, { id: id, dataStore: app.dataStore.data })

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
              console.log "Project", project
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
              console.log items
              app.dataStore.data.loadItems items

              ookook.util.get
                url: project.url + '/page'
                success: (pages) ->
                  console.log pages
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

  MITHGrid.defaults 'OokOok.Dashboard',
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
        type: OokOok.Presentation.NavList
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

  MITHGrid.defaults 'OokOok.Presentation.NavList',
    events:
      onCreateObject: null

  MITHGrid.defaults 'OokOok.Controller.CreateObjectUI',
    bind:
      events:
        onSelect: null

  MITHGrid.defaults 'OokOok.Controller.Click',
    bind:
      events:
        onSelect: null
