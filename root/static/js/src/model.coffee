ookook.namespace "model", (model) ->
  # we need a method to retrieve a collection and insert it into
  # the data store
  # we also need a way to create items and a way to respond to changes in
  # the data store
  model.initModel = (config) ->
    that = {}
    makeSubstitutions = (template, data) ->
      orig = template
      if template.indexOf("{?") >= 0
        bits = template.split('{?')
        for i in [0...bits.length]
          if i % 2 == 1
            mbs = bits[i].split("}")
            bits[i] = (data[mbs[0]]||'') + mbs[1]
        template = bits.join("")
      template

    that.getCollection = (info, cb) ->
      if $.isFunction(info)
        cb = info
        info = {}

      url = makeSubstitutions config.collection_url, info
      parent = makeSubstitutions config.parent, info

      ookook.util.get
        url: url
        success: (data) ->
          items = []
          for thing in data._embedded
            json = that.importItem thing
            json.parent = parent
            if !json.id? and config.buildId?
              json.id = config.buildId json
            items.push json
          config.dataStore.loadItems items
          if cb?
            cb(data._embedded)

    that.render = (container, presentation, model, id) ->
      rendering = {}
      # each of the things we belong to get rendered as 2x2 boxes
      if config?.schema?
        if config.schema.belongs_to?
          for k, v of config.schema.belongs_to
            console.log k

      rendering.update = (item) ->

      rendering.remove = ->
        $(container).empty()

      rendering

    that.importItem = (data) ->
      # use the config.schema to map data
      json = {}
      if config?.schema?
        if config.schema.properties?
          for k, v of config.schema.properties
            json[v.source || k] = data[k]
        if config.schema.belongs_to?
          # make sure we have each thing linked in
          for k, v of config.schema.belongs_to
            bits = data._links?[k]?.split("/")
            if bits?.length
              id = bits[bits.length-1]
              if id?
                json[v.source || k] = id
                if v.valueType? && config.application().model(v.valueType)?
                  config.application().model(v.valueType).load(id)
                    
      json.type = config.itemType || 'SectionLink'
      json.restType = config.restType
      json

    that.exportItem = (data) ->
      json = {}
      for k, v of config?.schema?.properties
        if v.is == "rw" and v.valueType != "hash"
          if data[v.source]?.length == 1
            json[k] = data[v.source][0]
          else if data[v.source]?.length > 1
            json[k] = data[v.source]
          else if data[v.source]?
            json[k] = null
      json

    that.schema = -> config.schema

    typeNames =
      Board: "Editorial Board"

    that.addConfig = (c) ->
      config = $.extend(config, true, c)

    that.inflateItem = (id) ->
      # we want to add links to various things
      # for each item in belongs_to, we have a linking item
      item = config.dataStore.getItem id
      items = []
      items.push $.extend {}, true, item, {
        id: "#{id}-factsheet"
        type: "FactSheet"
        parent: id
      }

      if config?.inflateItem?
        items = items.concat config.inflateItem(id)
      parents = MITHGrid.Data.Set.initInstance [ id ]
      newParents = parents
      newSize = parents.size()
      oldSize = 0
      while oldSize != newSize
        newParents = config.dataStore.getObjectsUnion(newParents, "parent")
        parents.add(x) for x in newParents.items()
        oldSize = newSize
        newSize = parents.size()
      
      if config?.schema?
        if config.schema.belongs_to?
          for k, v of config.schema.belongs_to
            if item[v.source || k]?
              for i in item[v.source || k]
                # if i is in the chain above us, then don't add it here
                if !parents.contains(i)
                  linkedItem = config.dataStore.getItem i
                  if linkedItem?.restType?
                    if typeNames[linkedItem.restType[0]]?
                      title = typeNames[linkedItem.restType[0]]
                    else
                      title = linkedItem.restType[0]
                  else
                    title = v.source || l
                  items.push
                    id: "#{id}-#{i}-link"
                    type: "ItemLink"
                    title: title
                    parent: id
                    link: i
      newItems = []
      updatedItems = []
      for item in items
        oldItem = config.dataStore.getItem item.id
        if oldItem.type?
          updatedItems.push item
        else
          newItems.push item
      config.dataStore.loadItems newItems
      config.dataStore.updateItems updatedItems

    that.deflateItem = (id) ->
      objects = MITHGrid.Data.Set.initInstance [ id ]
      objects = config.dataStore.getSubjectsUnion(objects, "parent")
      while objects.size() > 0
        config.dataStore.removeItems objects.items()
        objects = config.dataStore.getSubjectsUnion(objects, "parent")

    that.load = (info, id) ->
      if !id?
        id = info
        info = {}
      url = makeSubstitutions config.collection_url, info
      ookook.util.get
        url: url + '/' + id
        success: (data) ->
          json = that.importItem data
          json.restType = config.restType
          json.parent = config.parent
          if !json.id? and config.buildId?
            json.id = config.buildId json
          if config.dataStore.contains(id)
            config.dataStore.updateItems [ json ], ->
              list = config.dataStore.withParent(config.parent)
              count = list.length
              config.dataStore.updateItems [{
                id: config.parent
                badge: count
              }]
          else
            config.dataStore.loadItems [ json ], ->
              list = config.dataStore.withParent(config.parent)
              count = list.length
              config.dataStore.updateItems [{
                id: config.parent
                badge: count
              }]

    that.create = (data) ->
      url = makeSubstitutions config.collection_url, data
      json = that.exportItem data
      ookook.util.post
        url: url
        data: json
        success: (data) ->
          json = that.importItem data
          json.restType = config.restType
          json.parent = config.parent
          if !json.id and config.buildId?
            json.id = config.buildId json
          config.dataStore.loadItems [ json ]
          parentItem = config.dataStore.getItem config.parent
          config.dataStore.updateItems [{
            id: config.parent
            badge: parseInt(parentItem.badge[0],10) + 1
          }]

    that.delete = (info, id, cb) ->
      if $.isFunction(id)
        cb = id
        id = info
        info = {}
      url = makeSubstitutions config.collection_url, info
      ookook.util.delete
        url: url + '/' + id
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
      url = makeSubstitutions config.collection_url, item
      ookook.util.put
        url: url + '/' + item.id
        data: json

    that
