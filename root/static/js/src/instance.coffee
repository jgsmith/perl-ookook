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
        item = app.dataStore.data.getItem app.getMetroParent()
        if item["cmd-plus"]?
          formId = item["cmd-plus"][0] + "-new-form"
          console.log "Showing", formId
          $('#'+formId).modal('show')

    $("#cmd-edit").click ->
      if app.getAuthenticated()
        item = app.dataStore.data.getItem app.getMetroParent()
        if item["cmd-edit"]?
          formId = item["cmd-edit"][0] + "-edit-form"
          console.log "Showing", formId
          $('#'+formId).modal('show')

    $("#cmd-off").click ->
      if app.getAuthenticated()
        window.location.href = "/oauth/logout"

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
        app.model(item.restType[0]).inflateItem id

      if app.getAuthenticated()
        if item["cmd-edit"]?
          $("#li-edit").show()
        else
          $("#li-edit").hide()
        if item["cmd-plus"]?
          $("#li-plus").show()
        else
          $("#li-plus").hide()
      else
        $("#li-edit").hide()
        $("#li-plus").hide()

      # build breadcrumb
      crumbs = []
      tid = id
      while tid? and tid != "top"
        crumbs.push { id: tid, title: item.title[0] }
        tid = item.parent[0]
        item = app.dataStore.data.getItem tid
      $(".ookook-breadcrumb").empty()
      if crumbs.length > 10
        crumbs = crumbs[0..9]
        $(".ookook-breadcrumb").append($("<li>... <span class='divider'>/</span></li>"))
      if crumbs.length == 0
        $(".ookook-breadcrumb").hide()
      else
        $(".ookook-breadcrumb").show()

        crumbs.reverse()
       
        for crumb in crumbs
          if crumb.id == id
            li = $("<li class='active'></li>")
            li.text crumb.title
          else
            li = $("<li><a href='#'></a> <span class='divider'>/</span> </li>")
            li.find("a").text crumb.title
            ((c) -> li.find("a").click -> app.setMetroParent c)(crumb.id)
          $(".ookook-breadcrumb").append(li)

    initCollection = (model, nom) ->
      app.model(model).getCollection (list) ->
        app.dataStore.data.updateItems [{
          id: "section-#{nom}"
          badge: list.length
        }]

      #if model != "Board"
      #  ookook.component.newItemForm.initInstance $("##{model}-new-form"),
      #    application: -> app
      #    model: app.model(model)
      #  ookook.component.editItemForm.initInstance $("##{model}-edit-form"),
      #    application: -> app
      #    model: app.model(model)

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
             if info._links?.self? && info.dataType? && !app.model(info.dataType)?
               app.addModel info.dataType, ookook.model.initModel
                 collection_url: info._links.self
                 dataStore: app.dataStore.data
                 restType: info.dataType
                 parent: "section-#{key}"
                 schema: info.schema
                 application: -> app

             pi =
               id: "section-#{key}"
               type: 'SectionLink'
               rank: (if count == 1 then 2 else 1)
               parent: 'top'
               class: (if count == 1 then "primary" else "")
               order: 0
               badge: 0
               title: info.title
               model: info.dataType
             if key != "board"
               pi["cmd-plus"] = info.dataType
             items.push pi
        if data._links?
          for key, info of data._links
            if typeof info != "string"
              items.push
                id: "link-#{key}"
                parent: 'top'
                type: 'URLLink'
                link: info.url
                order: 10
                title: info.title
                class: (if info.dangerous then "danger" else "welcome")
        if data._text?
          for key, info of data._text
            if key == "top"
              parentId = key
            else
              items.push
                id: "text-#{key}"
                parent: info.parent || 'top'
                type: 'SectionLink'
                order: 5
                title: info.title
              parentId = "text-#{key}"
            if info._embedded?.sections?
              i = 0
              for s in info._embedded?.sections
                si =
                  id: "text-#{key}-section-#{i}"
                  parent: parentId
                  type: 'TextSection'
                  content: s.content
                  order: 1000
                  title: s.title
                if s.width?
                  si.width = s.width
                items.push si
                i += 1

        walkSitemap = (parent, map) ->
          i = 0
          items = []
          for n, s of map
            item =
              id: "#{parent}-#{i}"
              parent: parent
              title: n
              restType: "SitemapPage"
              type: "SectionLink"
            items.push item

            item =
              id: "#{parent}-#{i}-fs"
              parent: "#{parent}-#{i}"
              title: n
              restType: "SitemapPage"
              type: "FactSheet"
            if s.visual?
              item.page = s.visual
            items.push item

            if s.children?
              items = items.concat walkSitemap "#{parent}-#{i}", s.children
            i += 1
          items

        app.onModel 'Theme', (t) ->
          t.addConfig
            inflateItem: (id) ->
              pitems = []
              pitems.push
                id: id
                "cmd-plus": "ThemeLayout"
                "cmd-edit": "Theme"
              pitems

        app.onModel 'Project', (m) ->
          m.addConfig
            inflateItem: (id) ->
              pitems = []
              item = app.dataStore.data.getItem id
              # item.sitemap[0]
              if app.getAuthenticated() and item.sitemap?[0]?
                pitems.push
                  id: "#{id}-sitemap"
                  title: "Sitemap"
                  type: "SectionLink"
                  restType: "SitemapPage"
                  parent: id
                # now walk the sitemap and put up boxes for each page in
                # a level
                pi =
                  id: "#{id}-sitemap-0"
                  parent: "#{id}-sitemap"
                  title: "Home Page"
                  restType: "SitemapPage"
                  type: "FactSheet"
                if item.sitemap[0][""]?.visual?
                  pi.page = item.sitemap[0][""].visual
                  # TODO: Load page info
                pitems.push pi
                if item.sitemap[0][""]?.children?
                  pitems = pitems.concat walkSitemap "#{id}-sitemap-0", item.sitemap[0][""].children
              # now we want to make sure pages are loaded
              pitems.push
                id: "#{id}-pages"
                parent: id
                type: "SectionLink"
                title: "Pages"
                badge: 0
              app.model("Page").getCollection {
                project_id: id
              }, (list) ->
                # we want to update the number of pages
                app.dataStore.data.updateItems [
                  id: "#{id}-pages"
                  badge: list.length
                ]
              pitems

        ookook.util.get
          url: '/page'
          success: (data) ->
            app.addModel 'PagePart', ookook.model.initModel
              collection_url: '/page/{?page_id}/page-part/{?page_part_id}'
              dataStore: app.dataStore.data
              restType: 'PagePart'
              parent: "{?page_id}"
              schema:
                properties:
                  title:
                    is: 'rw'
                    source: 'title'
                    valueType: 'text'
                  content:
                    is: 'rw'
                    source: 'content'
                    valueType: 'text'
                  id:
                    is: 'ro'
                    source: 'id'
                    valueType: 'text'
                belongs_to:
                  page:
                    is: 'ro'
                    source: 'page'
              application: -> app
              buildId: (item) -> item.parent + "-part-" + item.title
              
            app.addModel 'Page', ookook.model.initModel
              collection_url: '/project/{?project_id}/page'
              dataStore: app.dataStore.data
              restType: 'Page'
              parent: "{?project_id}-pages"
              schema: data._schema
              application: -> app
              inflateItem: (id) ->
                item = app.dataStore.data.getItem id
                pitems = []
                if app.getAuthenticated()
                  pitems.push
                    id: "#{id}-factsheet"
                    parent: id
                    title: item.title
                    description: item.description
                    restType: "Page"
                    type: "FactSheet"
                  pitems.push
                    id: id
                    "cmd-plus": "PagePart"
                    "cmd-edit": "Page"
                  # now push an item for each page part
                  app.model('PagePart').getCollection {
                    page_id: id
                  }
                pitems

            #ookook.component.newItemForm.initInstance $("#PagePart-new-form"),
            #  application: -> app
            #  model: app.model("PagePart")
            #ookook.component.editItemForm.initInstance $("#PagePart-edit-form"),
            #  application: -> app
            #  model: app.model("PagePart")
            #ookook.component.newItemForm.initInstance $("#Page-new-form"),
            #  application: -> app
            #  model: app.model("Page")
            #ookook.component.editItemForm.initInstance $("#Page-edit-form"),
            #  application: -> app
            #  model: app.model("Page")

        ookook.util.get
          url: '/profile'
          error: ->
            app.setAuthenticated(false)
            app.dataStore.data.loadItems items
          success: (data) ->
            app.setAuthenticated(true)
            #items = []
            items.push
              id: 'section-settings'
              title: "Settings"
              mode: 'Item'
              type: "EmptyLink"
            items.push
              id: 'section-profile'
              title: 'Profile'
              type: 'SectionLink'
              mode: 'Item'
            items.push
              id: 'section-profile-services'
              title: 'Authentication Methods'
              order: 10
              type: 'Section',
              parent: 'section-profile'
            for service in data.services
              item =
                id: "oauth-#{service.name}"
                parent: 'section-profile-services'
                order: 10
                title: service.name
              if service.connected
                item.type = "URLLink"
                item.class = 'welcome'
              else
                item.type = "EmptyItem"
              items.push item
            app.dataStore.data.loadItems items
