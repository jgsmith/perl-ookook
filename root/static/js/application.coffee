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

  ookook.namespace "presentation", (presentation) ->
    presentation.namespace "metro", (metro) ->
      metro.initInstance = (args...) ->
        MITHGrid.Presentation.initInstance 'ookook.presentation.metro', args..., (that, container) ->
          options = that.options

          baseLens = (hubEl, presentation, model, itemId) ->
            rendering = {}

            item = model.getItem itemId

            el = $('<div></div>')
            rendering.el = el;
            hubEl.append(el)

            if item.title?
              title = $('<h1></h1>')
              title.text item.title[0]
              el.append title
            if item.description?
              description = $('<p></p>');
              description.text item.description[0]
              el.append description

            width = item.rank?[0] || 1

            classes = ""
            if item.class?
              classes = item.class.join " "

            el.attr
              class: "hub-item span" + (width * 2) + " " + classes

            finalHeight = el.height()
            finalWidth = el.width()
            el.height(0)
            el.width(0)
            el.attr
              opacity: 0

            el.animate {
              width: finalWidth
              height: finalHeight
              opacity: 1
            }, 750 * width

            rendering.remove = ->
              el.animate {
                width: 0
                height: 0
                opacity: 0
              }, 750 * width, ->
                el.remove()

            rendering

          that.startDisplayUpdate = ->

          that.finishDisplayUpdate = ->
            $(container).masonry
              itemSelector: '.hub-item'
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
              window.History.pushState {
                parent: options.application().getMetroParent()
              }, '', '/'
              options.application().setMetroParent item.id[0]

            rendering

  ookook.namespace "application", (apps) ->
    apps.namespace "top", (top) ->
      top.initInstance = (args...) ->
        MITHGrid.Application.initInstance 'ookook.application.top', args..., (that, container) ->
          that.ready ->
            that.events.onMetroParentChange.addListener (p) ->
              that.dataView.metroItems.setKey p
              item = that.dataView.metroItems.getItem p
              if item.parent?
                item = that.dataView.metroItems.getItem item.parent[0]
                if item.title?
                  $('#level-up').text item.title[0]
                else
                  $('#level-up').text "Up"
                $('#level-up').show()
                if $('#level-up').width() == 0
                  $('#level-up').animate {
                    width: 150
                    height: 75
                    opacity: 1
                  }, 250
        
MITHGrid.defaults 'ookook.application.top',
  dataStores:
    data:
      types:
        HubItem: {}
        Project: {}
        Library: {}
        Board: {}
      properties: {}
  dataViews:
    metroItems:
      dataStore: 'data'
      type: MITHGrid.Data.SubSet
      key: 'top',
      expressions: [ '!parent' ]
  variables:
    MetroParent:
      is: 'rw'
  presentations:
    top:
      type: ookook.presentation.metro
      container: " .ookook-hub"
      dataView: 'metroItems'
  viewSetup: """
    <div class="row">
      <div class="offset1 span10 ookook-hub"></div>
    </div>
  """
