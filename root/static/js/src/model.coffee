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
          for thing in data._embedded
            items.push that.importItem thing
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

      console.log "inflating", id
      if config?.inflateItem?
        console.log "calling out to inflateItem"
        items = items.concat config.inflateItem(id)
      if config?.schema?
        if config.schema.belongs_to?
          for k, v of config.schema.belongs_to
            if item[v.source || k]?
              for i in item[v.source || k]
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

    that.load = (id) ->
      ookook.util.get
        url: config.collection_url + '/' + id
        success: (data) ->
          json = that.importItem data
          json.restType = config.restType
          json.parent = config.parent
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
