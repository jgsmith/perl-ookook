MITHGrid.globalNamespace "ookook", (ookook) ->
  ookook.namespace "config", (config) ->
    config.url_base = '';

  ookook.namespace "util", (util) ->
    util.ajax = (config) ->
      ops =
        url: ookook.config.url_base + config.url
        type: config.type
        contentType: 'application/json'
        processData: false
        dataType: 'json'
        success: config.success
        error: config.error

      if config.data?
        ops.data = JSON.stringify config.data

      $.ajax ops

    util.get  = (config) -> util.ajax $.extend({ type: 'GET' },  config)
    util.post = (config) -> util.ajax $.extend({ type: 'POST' }, config)
    util.put  = (config) -> util.ajax $.extend({ type: 'PUT' },  config)
    util.delete  = (config) -> util.ajax $.extend({ type: 'DELETE' }, config)

    util.success_message = (msg) ->
      div = $("""
        <div class='alert alert-success'>
          <a class='close' data-dismiss='alert' href='#'>&times;</a>
          <h4 class='alert-heading'>Success!</h4>
        </div>
      """);
      div.append(msg);
      $("#messages").append(div);
      setTimeout ->
        div.animate {
          opacity: 0
        }, 1000, ->
          div.remove()
      , 2000

    util.error_message = (msg) ->
      div = $("""
        <div class='alert alert-error'>
          <a class='close' data-dismiss='alert' href='#'>&times;</a>
          <h4 class='alert-heading'>Uh oh!</h4>
        </div>
      """);
      div.append(msg);
      $("#messages").append(div);

  ookook.namespace "model", (model) ->
    # we need a method to retrieve a collection and insert it into
    # the data store
    # we also need a way to create items and a way to respond to changes in
    # the data store
    model.initModel = (config) ->
      that = {}
      that.getCollection = (cb) ->
        ookook.util.get
          url: config.collection_url
          success: (data) ->
            items = []
            for thing in data['_embedded']
              items.push that.importItem thing
            config.dataStore.loadItems items
            if cb?
              cb(data['_embedded'])

      that.importItem = (data) ->
        console.log "Importing", data
        # use the config.schema to map data
        json = {}
        for k, v of config?.schema?.properties
          json[v.source] = data[v]
        json.restType = config.restType
        json.parent = config.parent
        json

      that.exportItem = (data) ->
        json = {}
        for k, v of config?.schema?.properties
          if v.is == "rw" and v.valueType != "hash"
            if data[v.source].length == 1
              json[k] = data[v.source][0]
            else if data[v.source].length > 1
              json[k] = data[v.source]
            else
              json[k] = null
        json

      that.inflateItem = (id) ->

      that.deflateItem = (id) ->
        objects = MITHGrid.Data.Set.initInstance
          values: id
        objects = config.dataStore.getSubjectsUnion(objects, "parent")
        while objects.size() > 0
          config.dataStore.removeItems objects.items()
          objects = config.dataStore.getSubjectsUnion(objects, "parent")

      that.create = (data) ->
        json = that.exportItem data
        ookook.util.post
          url: config.collection_url
          data: json
          success: (data) ->
            json = that.importItem data
            json.restType = config.restType
            json.parent = config.parent
            config.dataStore.loadItems [ json ]
            parentItem = config.dataStore.getItem config.parent
            config.dataStore.updateItems [{
              id: config.parent
              badge: parseInt(parentItem.badge[0],10) + 1
            }]

      that.delete = (id, cb) ->
        ookook.util.delete
          url: config.collection_url + '/' + id
          success: ->
            that.deflateItem id
            config.dataStore.removeItems [ id ]
             
            parentItem = config.dataStore.getItem config.parent
            config.dataStore.updateItems [{
              id: config.parent
              badge: parseInt(parentItem.badge[0],10) - 1
            }]
            if cb?
              cb()

      that.update = (item) ->
        json = that.exportItem item
        ookook.util.put
          url: config.collection_url + '/' + item.id
          data: json

      that

  ookook.namespace "component", (component) ->
    component.namespace "modalForm", (modalForm) ->
      modalForm.initInstance = (args...) ->
        MITHGrid.initInstance 'ookook.component.modalForm', args..., (that, container) ->
          options = that.options
          id = $(container).attr('id')
          $(container).modal('hide')
          $("#" + id + "-cancel").click ->
            $(container).modal('hide')
          $("#" + id + "-action").click ->
            data = {}
            $(container).find('.modal-form-input').each (idx, el) ->
              el = $(el)
              elId = el.attr('id')
              elId = elId.substr(id.length + 1)
              data[elId] = el.val()
              if not $.isArray(data[elId])
                data[elId] = [ data[elId] ]
            $(container).modal('hide')
            if options.model?.create?
              options.model.create data

          $(container).on 'show', ->
            $(container).find('.modal-form-input').val("")

  ookook.namespace "presentation", (presentation) ->
    presentation.namespace "metroCtrl", (metroCtrl) ->
      metroCtrl.initInstance = (args...) ->
        MITHGrid.Presentation.initInstance 'ookook.presentation.metroCtrl', args..., (that, container) ->
          options = that.options

    presentation.namespace "metroNav", (metroNav) ->
      metroNav.initInstance = (args...) ->
        MITHGrid.Presentation.initInstance 'ookook.presentation.metroNav', args..., (that, container) ->
          options = that.options

          that.show = -> $(container).show()
          that.hide = -> $(container).hide()

          divider = $('<li class="divider"></li>')
          $(container).append(divider)

          home = $('<li></li>')
          homea = $('<a href="#" id="">Home</a>')
          home.append(homea)
          homea.click ->
            options.application().nextState
              parent: 'top'
              mode: 'List'

          divider.after(home)

          baseLens = (hubEl, presentation, model, itemId) ->
            rendering = {}

            item = model.getItem itemId

            el = $('<li></li>')
            rendering.el = el
            divider.before(el)

            a = $('<a href="#"></a>')
            el.append(a)
            rendering.a = a

            if item.title?
              a.text item.title[0]

            rendering.remove = ->
              el.remove()

            rendering.update = (item) ->
              if item.title?
                a.text item.title[0]
              else
                a.text ''

            rendering

          that.addLens 'URLLink', (hubEl, presentation, model, itemId) ->
            rendering = baseLens(hubEl, presentation, model, itemId)
            item = model.getItem itemId

            if item.link?
              link = item.link[0]
              $(rendering.a).click ->
                window.location.href = link

          that.addLens 'EmptyItem', baseLens

          that.addLens 'SectionLink', (hubEl, presentation, model, itemId) ->
            rendering = baseLens(hubEl, presentation, model, itemId)
            item = model.getItem itemId

            $(rendering.a).click -> 
              options.application().nextState
                parent: item.id[0]
                mode: 'List'

            rendering

          that.addLens 'ItemLink', (hubEl, presentation, model, itemId) ->
            rendering = baseLens(hubEl, presentation, model, itemId)
            item = model.getItem itemId
 
            $(rendering.a).click ->
              options.application().nextState
                parent: item.id[0]
                mode: 'Item'
              
          that.finishDisplayUpdate = ->

    presentation.namespace "metroItem", (metroItem) ->
      metroItem.initInstance = (args...) ->
        MITHGrid.Presentation.initInstance 'ookook.presentation.metroItem', args..., (that, container) ->
          options = that.options
          that.show = -> $(container).show()
          that.hide = -> $(container).hide()
          header = $("<header class='subhead' id='overview'></header>")
          $(container).append(header)
          $(container).attr
            'data-spy': 'scroll'

          headerTitle = $("<h1></h1>")
          header.append(headerTitle)
          itemType = $("<p class='type'></p>")
          header.append(itemType)
          headerDescription = $("<p class='lead'></p>")
          header.append(headerDescription)
          subNav = $("<div class='subnav subnav-fixed'></div>")
          
          subNavList = $("<ul class='nav nav-pills'><li><a href='#overview'>Top</a></li></ul>")
          subNav.append(subNavList)
          header.append(subNav)

          subNav.scrollspy()

          options.application().events.onMetroParentChange.addListener (p) ->
            item = options.dataView.getItem p
            headerTitle.text item.title?[0]
            itemType.text item.restType?[0]
            headerDescription.text item.description?[0]

          that.finishDisplayUpdate = ->
            subNav.scrollspy('refresh')

          superRender = that.render

          that.render = (c, m, i) ->
            innerContainer = $("<section></section>")
            innerContainer.attr
              id: 'section-' + i

            rendering = superRender(innerContainer, m, i)

            return unless rendering?

            container.append(innerContainer)

            item = m.getItem i
            pageHeader = $("<div class='page-header'></div>")
            innerContainer.prepend(pageHeader)
            pageHeaderH1 = $("<h2></h2>")
            pageHeaderH1.text(item.title[0])
            pageHeader.append(pageHeaderH1)

            navItem = $("<li></li>")
            navItemA = $("<a></a>")
            navItemA.attr
              href: '#section-' + i
            navItemA.text(item.title[0])
            navItem.append(navItemA)
            subNavList.append(navItem)

            superUpdate = rendering.update
            rendering.update = (item) ->
              pageHeaderH1.text(item.title[0])
              navItemA.text(item.title[0])
              superUpdate(item)

            superRemove = rendering.remove
            rendering.remove = ->
              navItem.remove()
              superRemove()
              innerContainer.remove()

            rendering

          that.addLens 'SectionLink', (container, presentation, model, id) ->
            rendering = {}
            item = model.getItem id
            if item.parent?[0] == "top"
              return

            # we want to provide a presentation of items here, but these items
            # can't be used to bring up new content - they can only be
            # added/removed/rearranged (if order is important)
            # items can be selected
            container.append($("<p>Stuff goes here</p>"))
            rendering.update = (item) ->

            rendering.remove = ->

            rendering

    presentation.namespace "metro", (metro) ->
      metro.initInstance = (args...) ->
        MITHGrid.Presentation.initInstance 'ookook.presentation.metro', args..., (that, container) ->
          options = that.options
          that.show = -> $(container).show()
          that.hide = -> $(container).hide()

          baseLens = (hubEl, presentation, model, itemId) ->
            rendering = {}

            item = model.getItem itemId

            el = $('<div></div>')
            rendering.el = el
            hubEl.append(el)
            badge = $('<span class="badge"></span>')
            el.append(badge)

            title = $('<h1></h1>')
            if item.title?
              title.text item.title[0]
            el.append title
            description = $('<p></p>');
            if item.description?
              description.text item.description[0]
            el.append description

            rendering.badge = badge
            rendering.description = description
            rendering.title = title

            if item.badge?
              badge.text item.badge[0]

            width = 2*(item.rank?[0] || 1)
            height = 2*(item.rank?[0] || 1)

            classes = ""
            if item.class?
              classes = item.class.join " "


            el.attr
              class: "tile width#{width} height#{height} #{classes}"

            finalHeight = el.height()
            finalWidth = el.width()
            el.height(0)
            el.width(0)

            el.animate {
              width: finalWidth
              height: finalHeight
            }, 200 * width, ->
              el.attr
                width: null
                height: null

            rendering.update = (item) -> 
              if item.description?
                description.text item.description[0]
              else
                description.text ''
              if item.title?
                title.text item.title[0]
              else
                title.text ''
              if item.badge?
                badge.text item.badge[0]
              else
                badge.text ''

            rendering.remove = ->
              el.animate {
                width: 0
                height: 0
                opacity: 0
              }, 200 * width, ->
                el.remove()

            rendering

          that.startDisplayUpdate = ->

          that.finishDisplayUpdate = ->
            $(container).masonry
              itemSelector: '.tile'
              columnWidth: 75

          that.addLens 'URLLink', (hubEl, presentation, model, itemId) ->
            rendering = baseLens(hubEl, presentation, model, itemId)
            item = model.getItem itemId

            if item.link?
              link = item.link[0]
              $(rendering.el).click ->
                window.location.href = link

          that.addLens 'EmptyItem', baseLens

          that.addLens 'SectionLink', (hubEl, presentation, model, itemId) ->
            rendering = baseLens(hubEl, presentation, model, itemId)
            item = model.getItem itemId

            $(rendering.el).click -> 
              options.application().nextState
                parent: item.id[0]

            rendering

          that.addLens 'ItemLink', (hubEl, presentation, model, itemId) ->
            rendering = baseLens(hubEl, presentation, model, itemId)
            item = model.getItem itemId
 
            $(rendering.a).click ->
              options.application().nextState
                parent: item.id[0]

  ookook.namespace "application", (apps) ->
    apps.namespace "top", (top) ->
      top.initInstance = (args...) ->
        MITHGrid.Application.initInstance 'ookook.application.top', args..., (that, container) ->
          that.pushState = ->
            window.History.pushState {
              parent: that.getMetroParent()
              mode: that.getMetroMode()
            }, '', '/'
          that.nextState = (opts) ->
            that.pushState()
            oldParent = that.getMetroParent()
            oldMode = that.getMetroMode()

            that.setMetroParent(opts.parent) if opts.parent?
            item = that.dataStore.data.getItem that.getMetroParent()
            if opts.mode?
              that.setMetroMode(opts.mode)
            else
              if item?.mode?
                that.setMetroMode(item.mode[0])
              else if item?.restType?
                that.setMetroMode('Item')
              else
                that.setMetroMode('List')

            newMode = that.getMetroMode()

            if oldMode == "Item" and newMode == "List" and item.parent == "top"
              # remove items to which oldParent pointed
              # this is based on the equivalent of !parent for this id
              oldItem = that.dataStore.data.getItem oldParent
              if oldItem.restType? and models[oldItem.restType?[0]]?
                models[oldItem.restType[0]].deflate oldParent
              else
                that.dataStore.data.removeItems that.dataStore.data.withParent(oldParent)

          models = {}

          that.addModel = (nom, model) -> models[nom] = model
          that.model = (nom) -> models[nom]

          that.dataStore.data.withParent = (p) ->
            objects = MITHGrid.Data.Set.initInstance
              values: oldParent
            that.dataStore.data.getSubjectsUnion(objects, "parent").items()

          that.ready ->
            that.events.onMetroParentChange.addListener (p) ->
              that.dataView.metroItems.setKey p
              item = that.dataStore.data.getItem p
              if item.title?
                $('#section-header').text item.title[0]
              if p == "top"
                $('#section-header').text "Home"
              if item.restType? && that.getAuthenticated()
                $('#li-trash').show()
              else
                $('#li-trash').hide()

            that.events.onMetroModeChange.addListener (m) ->
              if m == "List"
                that.presentation.list.show()
                that.presentation.item.hide()
              else
                that.presentation.list.hide()
                that.presentation.item.show()

            that.setMetroMode("List")

            that.dataView.metroItems.events.onModelChange.addListener (model, itemIds) ->
              for id in itemIds
                item = model.getItem id
                if item.type and ("Command" in item.type)
                    liId = '#li-' + item.commandType[0]
                    if model.contains(id) and (!item.requiresAuthenticated?[0] or that.getAuthenticated())
                      $(liId).show()
                    else
                      $(liId).hide()

MITHGrid.defaults 'ookook.application.top',
  dataStores:
    data:
      types:
        SectionLink: {}
        URLLink: {}
        Project: {}
        Library: {}
        Board: {}
        BoardRank: {}
        Page: {}
        PagePart: {}
      properties:
        board_ranks:
          valueType: 'item'
        pages:
          valueType: 'item'
        parent:
          valueType: 'item'
  dataViews:
    metroItems:
      dataStore: 'data'
      type: MITHGrid.Data.SubSet
      key: 'top',
      expressions: [ '!parent' ]
    metroTopItems:
      dataStore: 'data'
      type: MITHGrid.Data.SubSet
      key: 'top',
      expressions: [ '!parent' ]
  variables:
    MetroParent:
      is: 'rw'
      default: 'top'
    MetroMode:
      is: 'rw'
      default: 'list'
    Authenticated:
      is: 'rw'
      default: false
  presentations:
    list:
      type: ookook.presentation.metro
      container: " .ookook-hub"
      dataView: 'metroItems'
    item:
      type: ookook.presentation.metroItem
      container: " .ookook-item"
      dataView: 'metroItems'
    nav:
      type: ookook.presentation.metroNav
      container: " .ookook-nav"
      dataView: 'metroTopItems'
  viewSetup: """
    <div class="navbar navbar-fixed-top">
     <div class="navbar-inner">
       <div class="container">
         <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
           <span class="icon-bar"></span>
           <span class="icon-bar"></span>
           <span class="icon-bar"></span>
         </a>
         <a class="brand" href="#" id="top-nav">OokOok</a>
         <div class="nav-collapse">
           <ul class="nav">
             <li class="dropdown">
               <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                 <span id="section-header">Home</span>
                 <b class="caret"></b>
               </a>
              <ul class='dropdown-menu ookook-nav'></ul>
             </li>
           </ul>
         </div>
       </div>
     </div>
    </div>
    <div class="row-fluid">
      <div class="span12 ookook-hub"></div>
    </div>
    <div>
      <div class="span12 ookook-item" data-spy='scroll' data-target='.subnav' data-offset='60'></div>
    </div>
    <div class="navbar navbar-fixed-bottom">
      <div class="navbar-inner">
        <div class="container">
          <ul class="nav pull-right" id="right-commands">
            <li class="divider-vertical"></li>
            <li id="li-trash" style="display: none;"><a href="#" id="cmd-trash"><i class="icon-trash icon-white"></i></a></li>
            <li id="li-remove" style="display: none;"><a href="#" id="cmd-remove"><i class="icon-remove icon-white"></i></a></li>
            <li id="li-plus" style="display: none;"><a href="#" id="cmd-plus"><i class="icon-plus icon-white"></i></a></li>
          </ul>
          <ul class="nav pull-left">
            <li id="li-home"><a href="#" id="cmd-home"><i class="icon-home icon-white"></i></a></li>
          </ul>
        </div>
      </div>
    </div>
  """

$ ->
  app = ookook.application.top.initInstance $('#browser-container')
  ookook.application.top.instance = app
  app.run()

  app.ready ->
    $("#top-nav").click ->
      app.nextState
        parent: 'top'
        mode: 'List'
    $("#cmd-home").click ->
      app.nextState
        parent: 'top'
        mode: 'List'

    $("#cmd-plus").click ->
      if app.getAuthenticated()
        formId = app.getMetroParent() + "-new-form"
        $('#'+formId).modal('show')

    bits = window.location.href.split '#'
    if bits.length > 1
      if bits[1] == ""
        bits[1] = "top"
      app.setMetroParent bits[1]
    else
      app.setMetroParent "top"

    $("#li-trash").click ->
      if app.getAuthenticated()
        item = app.dataStore.data.getItem app.getMetroParent()
        if item.restType? and app.model(item.restType[0])?
          if confirm("Delete " + item.title[0] + "?")
            app.model(item.restType[0]).delete item.id, ->
              app.setMetroParent item.parent[0]

    app.events.onMetroParentChange.addListener (id) ->
      item = app.dataStore.data.getItem id
      if item.restType? and app.model(item.restType[0])?
        app.model(item.restType[0]).inflate id

    initCollection = (model, nom) ->
      app.model(model).getCollection (list) ->
        if model != "Board"
          app.dataStore.data.loadItems [{
            id: "section-#{nom}-new"
            parent: "section-#{nom}"
            type: 'Command'
            commandType: 'plus'
            requiresAuthenticated: true
          }]

        app.dataStore.data.updateItems [{
          id: "section-#{nom}"
          badge: list.length
        }]

      ookook.component.modalForm.initInstance $("#section-#{nom}-new-form"),
        application: -> app
        model: app.model(model)

    collections = []
    app.dataView.metroTopItems.events.onModelChange.addListener (dm, itemIds) ->
      for id in itemIds
        continue if id in collections
        item = dm.getItem id
        continue unless "SectionLink" in item.type
        continue unless item.id[0][0...8] == "section-"
        nom = item.id[0][8...item.id[0].length]
        model = item.model?[0]
        if nom? and nom != "" and model? and app.model(model)?
          collections.push id
          initCollection model, nom

    ookook.util.get
      url: '/'
      success: (data) ->
        items = []

        if data._embedded?
          count = 0
          for info in data._embedded
             count += 1
             key = info.id
             if info._links?.self? && info.dataType?
               app.addModel info.dataType, ookook.model.initModel
                 collection_url: info._links.self
                 dataStore: app.dataStore.data
                 restType: info.dataType
                 parent: "section-#{key}"
                 schema: info.schema

             items.push
               id: "section-#{key}"
               type: 'SectionLink'
               rank: (if count == 1 then 2 else 1)
               parent: 'top'
               class: (if count == 1 then "primary" else "")
               badge: 0
               title: info.title
               model: info.dataType
        if data._text?
          for key, info of data._text
            items.push
              id: "text-#{key}"
              parent: 'top'
              type: 'EmptyItem'
              title: info.title

        if data._links?
          for key, info of data._links
            if typeof info != "string"
              items.push
                id: "link-#{key}"
                parent: 'top'
                type: 'URLLink'
                link: info.url
                title: info.title
                class: (if info.dangerous then "danger" else "welcome")
        console.log items
        app.dataStore.data.loadItems items
        ookook.util.get
          url: '/profile'
          success: (data) ->
            app.setAuthenticated(true)
            items = []
            items.push
              id: "section-settings"
              parent: 'top'
              title: "Settings"
              mode: 'Item'
              type: "EmptyLink"
            items.push
              id: 'section-profile'
              title: 'Profile'
              type: 'SectionLink'
              mode: 'Item'
              parent: 'top'
            items.push
              id: 'section-profile-services'
              title: 'Authentication Methods'
              type: 'Section',
              parent: 'section-profile'
            for service in data.services
              item =
                id: "oauth-#{service.name}"
                parent: 'section-profile-services'
                title: service.name
              if service.connected
                item.type = "URLLink"
                item.class = 'welcome'
              else
                item.type = "EmptyItem"
              items.push item
            if data._links?
              for key, info of data._links
                if typeof info != "string"
                  items.push
                    id: "link-#{key}"
                    parent: 'top'
                    type: 'URLLink'
                    link: info.url
                    title: info.title
                    class: (if info.dangerous then "danger" else "welcome")
            app.dataStore.data.loadItems items
